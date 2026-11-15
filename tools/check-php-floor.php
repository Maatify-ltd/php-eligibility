<?php

declare(strict_types=1);

printf("Running PHP %s\n", PHP_VERSION);

$minimumByMinor = [
    '8.4' => '8.4.27',
    '8.5' => '8.5.12',
];
$minor = implode('.', array_slice(explode('.', PHP_VERSION), 0, 2));
$minimum = $minimumByMinor[$minor] ?? null;

if ($minimum === null || version_compare(PHP_VERSION, $minimum, '<')) {
    fwrite(STDERR, "CI requires PHP 8.4.27+ or 8.5.12+ within the corresponding minor.\n");
    exit(1);
}
