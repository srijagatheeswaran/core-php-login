<?php

require_once __DIR__ . '/../../vendor/autoload.php';


function loadEnv()
{
    $dotenv = Dotenv\Dotenv::createImmutable(dirname(__DIR__, 2));
    $dotenv->load();
}

