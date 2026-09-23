<?php
const VERSAO_TERMOS = '1.0';
function textoTermos(): string
{
    return file_get_contents(__DIR__ . '/../../views/termos-conteudo.php');
}
