<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once './database/mysql.php';
require_once './config/config.php';
loadEnv();
$redis = require_once './database/redis.php';

header('Content-Type: application/json');

$email = trim($_POST['email'] ?? '');
$password = trim($_POST['password'] ?? '');

if (empty($email) || empty($password)) {
    echo json_encode(['status' => 'error', 'message' => 'All fields are required']);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM users WHERE email = :email LIMIT 1");
$stmt->execute(['email' => $email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user && password_verify($password, $user['password'])) {
    $token = bin2hex(random_bytes(32));
    $id = $user['id'];
    
    $redis->set("session:user:$id",$token); 

    echo json_encode(['status' => 'success', 'message' => 'Login successful', 'token' => $token, 'user' => $user['id']]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid email or password']);
}
