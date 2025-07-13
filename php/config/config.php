<?php

require_once __DIR__ . '/../vendor/autoload.php';

function loadEnv()
{
    $dotenv = Dotenv\Dotenv::createImmutable('/var/www/html');
    $dotenv->load();
}

