<?php

// Suppress warnings (optional if Predis throws deprecated errors)
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');

require_once __DIR__ . '/config/config.php';
loadEnv();
require_once __DIR__ . '/database/mysql.php';
require_once __DIR__ . '/database/redis.php';

$username = trim($_POST['username'] ?? '');
$email = trim($_POST['email'] ?? '');
$password = trim($_POST['password'] ?? '');
$confirmPassword = trim($_POST['confirmPassword'] ?? '');

if (empty($username) || empty($email) || empty($password) || empty($confirmPassword)) {
    echo json_encode(['status' => 'error', 'message' => 'All fields are required']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid email address']);
    exit;
}

if ($password !== $confirmPassword) {
    echo json_encode(['status' => 'error', 'message' => 'Passwords do not match']);
    exit;
}

// Check if user already exists
$stmt = $conn->prepare("SELECT id FROM users WHERE username = :username OR email = :email LIMIT 1");
$stmt->execute(['username' => $username, 'email' => $email]);

if ($stmt->fetch()) {
    echo json_encode(['status' => 'error', 'message' => 'Username or email already exists']);
    exit;
}

// Hash the password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Insert user
$stmt = $conn->prepare("INSERT INTO users (username, email, password) VALUES (:username, :email, :password)");

try {
    $stmt->execute([
        'username' => $username,
        'email' => $email,
        'password' => $hashedPassword
    ]);

    // Get the inserted user ID
    $userId = $conn->lastInsertId();

    // Generate a token
    $token = bin2hex(random_bytes(32));

      $id = $userId;

    $redisClient->set("session:user:$id",$token);

    echo json_encode([
        'status' => 'success',
        'message' => 'Registration successful',
        'token' => $token,
        'user' => $userId
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Registration failed: ' . $e->getMessage()]);
}
