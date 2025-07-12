<?php
header('Content-Type: application/json');

require_once './database/mysql.php';
require_once './database/redis.php';
require_once './database/mongodb.php';
require_once './auth.php';
loadEnv();

$userId = authenticate();
if ($userId === '') {
    echo json_encode(['status' => 'error', 'message' => 'User ID is required']);
    exit;
}

$username = trim($_POST['username'] ?? '');
$email = trim($_POST['email'] ?? '');
$phone = trim($_POST['phone'] ?? '');
$location = trim($_POST['location'] ?? '');

if ($username === '' || $email === '') {
    echo json_encode(['status' => 'error', 'message' => 'Username and Email are required']);
    exit;
}

try {
    $stmt = $conn->prepare("UPDATE users SET username = :username, email = :email WHERE id = :id");
    $stmt->execute([
        'username' => $username,
        'email' => $email,
        'id' => $userId
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'MySQL update failed: ' . $e->getMessage()]);
    exit;
}

$uploadPath = '';
if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] === UPLOAD_ERR_OK) {
    $fileTmp = $_FILES['profile_image']['tmp_name'];
    $fileName = basename($_FILES['profile_image']['name']);
    $fileSize = $_FILES['profile_image']['size'];
    $fileType = mime_content_type($fileTmp);
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

    if (!in_array($fileType, $allowedTypes)) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid image format']);
        exit;
    }

    if ($fileSize > 2 * 1024 * 1024) {
        echo json_encode(['status' => 'error', 'message' => 'Image size exceeds 2MB']);
        exit;
    }

    $ext = pathinfo($fileName, PATHINFO_EXTENSION);
    $newName = uniqid("img_", true) . "." . $ext;

    $uploadDir = __DIR__ . '/../uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $destination = $uploadDir . $newName;
    if (!move_uploaded_file($fileTmp, $destination)) {
        echo json_encode(['status' => 'error', 'message' => 'Failed to save image']);
        exit;
    }


    $uploadPath = 'uploads/' . $newName;
}

$collection = $db->user;

$updateData = ['phone' => $phone, 'location' => $location];
if ($uploadPath) {
    $updateData['profile_image'] = $uploadPath;
}

try {
    $collection->updateOne(
        ['user_id' => (int)$userId],
        ['$set' => $updateData],
        ['upsert' => true]
    );
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'MongoDB update failed: ' . $e->getMessage()]);
    exit;
}

echo json_encode(['status' => 'success', 'message' => 'Profile updated successfully']);
