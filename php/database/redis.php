<?php

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../config/config.php';

loadEnv();

try {
    $redisClient = new Predis\Client([
        'host' => $_ENV['REDIS_HOST'] ?? null,
        'port' => $_ENV['REDIS_PORT'] ?? null,
        'username' => $_ENV['REDIS_USERNAME'] ?? null,
        'password' => $_ENV['REDIS_PASSWORD'] ?? null,
    ]);
    // Test the connection
    $redisClient->connect();
    return $redisClient;
} catch (Predis\ClientException $e) {
    error_log("Redis Client Exception: " . $e->getMessage());
    return null;
} catch (Exception $e) {
    error_log("General Exception during Redis connection: " . $e->getMessage());
    return null;
}


