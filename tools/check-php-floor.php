<?php

declare(strict_types=1);

printf("Running PHP %s\n", PHP_VERSION);

$minimum = match (PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION) {
    '8.4' => '8.4.27',
    '8.5' => '8.5.12',
    default => null,
};

if ($minimum === null || version_compare(PHP_VERSION, $minimum, '<')) {
    fwrite(STDERR, "CI requires PHP 8.4.27+ or 8.5.12+ within the corresponding minor.\n");
    exit(1);
}
