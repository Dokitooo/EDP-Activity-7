<?php
// ─── backend.php ──────────────────────────────────────────────────────────────
// Handles: login, logout, forgot password, add/update/toggle/list users
// ─────────────────────────────────────────────────────────────────────────────

session_start();
header('Content-Type: application/json');

// ── Public Database Class ─────────────────────────────────────────────────────
class Database
{
    public string $host = 'localhost';
    public string $dbname = 'college_information_system';
    public string $user = 'root';
    public string $pass = '';          // change to your MySQL password
    public ?PDO $conn = null;

    public function connect(): PDO
    {
        if ($this->conn)
            return $this->conn;
        $dsn = "mysql:host={$this->host};dbname={$this->dbname};charset=utf8mb4";
        $this->conn = new PDO($dsn, $this->user, $this->pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        return $this->conn;
    }
}

// ── Bootstrap ─────────────────────────────────────────────────────────────────
$db = new Database();
$pdo = $db->connect();

// First-run seed: create default admin if the users table is empty
$count = (int) $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
if ($count === 0) {
    $pdo->prepare(
        "INSERT INTO users (username, full_name, email, password, status)
         VALUES (?, ?, ?, ?, 'active')"
    )->execute([
                'admin',
                'System Administrator',
                'admin@college.edu',
                password_hash('admin123', PASSWORD_DEFAULT),
            ]);
}

// ── Helper ────────────────────────────────────────────────────────────────────
function resp(bool $ok, $data = [], string $msg = ''): void
{
    echo json_encode(['ok' => $ok, 'msg' => $msg, 'data' => $data]);
    exit;
}

// ── Route ─────────────────────────────────────────────────────────────────────
$action = $_POST['action'] ?? '';

// Guard protected actions
$protected = ['list_users', 'add_user', 'update_user', 'toggle_status'];
if (in_array($action, $protected) && empty($_SESSION['user_id'])) {
    resp(false, [], 'Session expired. Please log in again.');
}

switch ($action) {

    // ── Login ─────────────────────────────────────────────────────────────────
    case 'login':
        $username = trim($_POST['username'] ?? '');
        $password = $_POST['password'] ?? '';

        if (!$username || !$password) {
            resp(false, [], 'Username and password are required.');
        }

        $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? LIMIT 1");
        $stmt->execute([$username]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password'])) {
            resp(false, [], 'Invalid username or password.');
        }
        if ($user['status'] === 'inactive') {
            resp(false, [], 'Your account is inactive. Contact an administrator.');
        }

        $_SESSION['user_id'] = $user['user_id'];
        $_SESSION['username'] = $user['username'];
        $_SESSION['full_name'] = $user['full_name'];

        resp(true, [
            'full_name' => $user['full_name'],
            'username' => $user['username'],
        ]);

    // ── Logout ────────────────────────────────────────────────────────────────
    case 'logout':
        session_destroy();
        resp(true);

    // ── Forgot / Password Recovery ────────────────────────────────────────────
    case 'forgot':
        $input = trim($_POST['input'] ?? '');
        if (!$input)
            resp(false, [], 'Please enter your username or email.');

        $stmt = $pdo->prepare(
            "SELECT user_id FROM users WHERE username = ? OR email = ? LIMIT 1"
        );
        $stmt->execute([$input, $input]);
        $user = $stmt->fetch();

        if ($user) {
            $token = bin2hex(random_bytes(20));
            $expires = date('Y-m-d H:i:s', strtotime('+30 minutes'));
            $pdo->prepare(
                "UPDATE users SET reset_token = ?, reset_expires = ? WHERE user_id = ?"
            )->execute([$token, $expires, $user['user_id']]);
            // In production: send email with reset link containing $token
        }

        // Always return OK — do not reveal whether the account exists
        resp(true, [], 'If the account exists, a reset link has been sent to the registered email.');

    // ── List / Search Users ───────────────────────────────────────────────────
    case 'list_users':
        $search = '%' . trim($_POST['search'] ?? '') . '%';
        $status = $_POST['status'] ?? '';

        $sql = "SELECT user_id, username, full_name, email, status, created_at
                   FROM users
                   WHERE (username LIKE ? OR full_name LIKE ? OR email LIKE ?)";
        $params = [$search, $search, $search];

        if ($status !== '') {
            $sql .= " AND status = ?";
            $params[] = $status;
        }

        $sql .= " ORDER BY created_at DESC";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        resp(true, $stmt->fetchAll());

    // ── Add Account ───────────────────────────────────────────────────────────
    case 'add_user':
        $username = trim($_POST['username'] ?? '');
        $full_name = trim($_POST['full_name'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';

        if (!$username || !$full_name || !$email || !$password) {
            resp(false, [], 'All fields are required.');
        }

        try {
            $pdo->prepare(
                "INSERT INTO users (username, full_name, email, password, status)
                 VALUES (?, ?, ?, ?, 'active')"
            )->execute([
                        $username,
                        $full_name,
                        $email,
                        password_hash($password, PASSWORD_DEFAULT),
                    ]);
            resp(true, [], 'Account created successfully.');
        } catch (PDOException $e) {
            resp(false, [], 'Username or email already exists.');
        }

    // ── Update Account Profile ────────────────────────────────────────────────
    case 'update_user':
        $id = (int) ($_POST['user_id'] ?? 0);
        $full_name = trim($_POST['full_name'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';

        if (!$id || !$full_name || !$email) {
            resp(false, [], 'Full name and email are required.');
        }

        try {
            if ($password) {
                $pdo->prepare(
                    "UPDATE users SET full_name = ?, email = ?, password = ? WHERE user_id = ?"
                )->execute([$full_name, $email, password_hash($password, PASSWORD_DEFAULT), $id]);
            } else {
                $pdo->prepare(
                    "UPDATE users SET full_name = ?, email = ? WHERE user_id = ?"
                )->execute([$full_name, $email, $id]);
            }
            resp(true, [], 'Account updated successfully.');
        } catch (PDOException $e) {
            resp(false, [], 'Email already in use by another account.');
        }

    // ── Activate / Deactivate Account ─────────────────────────────────────────
    case 'toggle_status':
        $id = (int) ($_POST['user_id'] ?? 0);

        // Prevent admin from deactivating themselves
        if ($id === (int) $_SESSION['user_id']) {
            resp(false, [], 'You cannot change the status of your own account.');
        }

        $stmt = $pdo->prepare("SELECT status FROM users WHERE user_id = ?");
        $stmt->execute([$id]);
        $row = $stmt->fetch();

        if (!$row)
            resp(false, [], 'User not found.');

        $new = $row['status'] === 'active' ? 'inactive' : 'active';
        $pdo->prepare("UPDATE users SET status = ? WHERE user_id = ?")
            ->execute([$new, $id]);

        resp(true, ['status' => $new], 'Status updated to ' . $new . '.');

    default:
        resp(false, [], 'Unknown action.');

    // ── GYM TRANSACTIONS ──────────────────────────────────────────────────────────

    case 'get_transaction_data':
        $plans = $pdo->query("SELECT * FROM membership_plans")->fetchAll();
        $prods = $pdo->query("SELECT * FROM products")->fetchAll();
        $users = $pdo->query("SELECT user_id, full_name FROM users WHERE status='active'")->fetchAll();
        resp(true, ['plans' => $plans, 'products' => $prods, 'users' => $users]);

    case 'transact_sub':
        $u_id = $_POST['user_id'];
        $p_id = $_POST['plan_id'];
        $plan = $pdo->query("SELECT duration_days FROM membership_plans WHERE plan_id=$p_id")->fetch();
        $start = date('Y-m-d');
        $end = date('Y-m-d', strtotime("+{$plan['duration_days']} days"));
        $pdo->prepare("INSERT INTO member_subscriptions (user_id, plan_id, start_date, end_date) VALUES (?,?,?,?)")
            ->execute([$u_id, $p_id, $start, $end]);
        resp(true, [], 'Subscription recorded.');

    case 'transact_checkin':
        $pdo->prepare("INSERT INTO attendance (user_id) VALUES (?)")->execute([$_POST['user_id']]);
        resp(true, [], 'Check-in recorded.');

    case 'transact_sale':
        $u_id = $_POST['user_id'];
        $pr_id = $_POST['prod_id'];
        $prod = $pdo->query("SELECT price FROM products WHERE prod_id=$pr_id")->fetch();
        $pdo->prepare("INSERT INTO sales (user_id, prod_id, total_amount) VALUES (?,?,?)")
            ->execute([$u_id, $pr_id, $prod['price']]);
        resp(true, [], 'Sale recorded.');

    case 'fetch_report':
        $type = $_POST['type'];
        if ($type == 'subs') {
            $data = $pdo->query("SELECT s.sub_id as ID, u.full_name as Member, p.plan_name as Plan, s.end_date as Expiry FROM member_subscriptions s JOIN users u ON s.user_id=u.user_id JOIN membership_plans p ON s.plan_id=p.plan_id")->fetchAll();
        } elseif ($type == 'sales') {
            $data = $pdo->query("SELECT sl.sale_id as ID, u.full_name as Member, pr.prod_name as Item, sl.total_amount as Amount FROM sales sl JOIN users u ON sl.user_id=u.user_id JOIN products pr ON sl.prod_id=pr.prod_id")->fetchAll();
        } else {
            $data = $pdo->query("SELECT a.att_id as ID, u.full_name as Member, a.check_in_time as Time FROM attendance a JOIN users u ON a.user_id=u.user_id")->fetchAll();
        }
        resp(true, $data);
}
