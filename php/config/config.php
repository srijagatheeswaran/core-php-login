<?php

// require_once __DIR__ . '/../../vendor/autoload.php';


// function loadEnv()
// {
//     $dotenv = Dotenv\Dotenv::createImmutable(dirname(__DIR__, 2));
//     $dotenv->load();
// }

require_once __DIR__ . '/../../vendor/autoload.php';

use Dotenv\Dotenv;

function loadEnv()
{
    $envPath = dirname(__DIR__, 2);

    if (file_exists($envPath . '/.env')) {
        $dotenv = Dotenv::createImmutable($envPath);
        $dotenv->load();
    }
}


