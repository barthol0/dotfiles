<?php declare(strict_types=1);

use PhpCsFixer\Config;
use PhpCsFixer\Finder;

$rules = [
    '@PHP81Migration' => true,
    '@PHP82Migration' => true,
    '@PSR12' => true,
    'array_indentation' => true,
    'blank_line_after_opening_tag' => false,
    'blank_line_before_statement' => [
        'statements' => [
            'break',
            'continue',
            'declare',
            'default',
            'exit',
            'goto',
            'for',
            'foreach',
            'if',
            'include',
            'include_once',
            'require',
            'require_once',
            'return',
            'switch',
            'throw',
            'try',
            'yield',
        ],
    ],
    'class_attributes_separation' => [
        'elements' => [
            'trait_import' => 'none',
            'const' => 'none',
            'property' => 'none',
            'method' => 'one',
        ],
    ],
    'declare_strict_types' => true,
    'no_superfluous_phpdoc_tags' => [
        'allow_mixed' => true,
        'allow_unused_params' => false,
        'remove_inheritdoc' => false,
    ],
    'no_trailing_comma_in_singleline' => [
        'elements' => [
            'arguments',
            'array_destructuring',
            'array',
            'group_import',
        ],
    ],
    'trim_array_spaces' => true,
];

return (new Config())
    ->setCacheFile(__DIR__.'/tmp/.php-cs-fixer.cache')
    ->setRules($rules)
    ->setFinder(Finder::create());
