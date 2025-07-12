<?php

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../config/config.php';

loadEnv();

error_log("MONGO_URI (from _ENV): " . ($_ENV['MONGO_URI'] ?? 'NOT SET'));
error_log("MONGO_DB_NAME (from _ENV): " . ($_ENV['MONGO_DB_NAME'] ?? 'NOT SET'));

$mongoUri = $_ENV['MONGO_URI'] ?? null;
$mongoDbName = $_ENV['MONGO_DB_NAME'] ?? null;

if (!$mongoUri || !$mongoDbName) {
    error_log("MongoDB connection details not found in the .env file.");
    return null;
}

try {
    $client = new MongoDB\Client($mongoUri);
    $db = $client->selectDatabase($mongoDbName);
    return $db;
} catch (Exception $e) {
    error_log("Could not connect to MongoDB: " . $e->getMessage());
    return null;
}
