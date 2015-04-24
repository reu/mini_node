# MiniNode

Os exemplos estão na pasta `bin`.

# Exercícios

## Exercício: Redis
Redis possui um protocolo text based extremamente simples. Veja um exemplo (que fiz usando apenas o `netcat`):

```
SET nome "Rodrigo Navarro"
+OK
GET nome
$15
"Rodrigo Navarro"
```

Então basicamente, o comando `SET <key> <value>` retorna um status de sucesso ou erro, seguido de um \n.
O `GET <value>` retorna um $, seguido do número de bytes da resposta, seguido de um \n, seguido dos dados da chave.

O exercício é implementar uma versão assíncrona de um client para o Redis que aceite os comandos `GET` e `SET`.

## Servir páginas estáticas via HTTP
Seguindo o exemplo utilizando o `http_parser.rb`, expanda-o para que seja possível servir páginas estáticas assíncronamente. 
Por curiosidade, faça um `ab` utilizando essa nossa simples implementação contra algum servidor rodando Unicorn ou Puma servindo arquivos estáticos, e os assistam sendo humilhados =]

## nio4r
Implementamos um reactor usando `select(2)`, mas sabemos que essa não é a melhor solução. O nio4r é uma gem que faz bindings para o Ruby de funções **bem** melhores que o `select(2)` para um reactor.
O exercício é tentar manter a nossa mesma API, mas implementando utilizando o nio4r. Na wiki deles, tem essa página que vai ajudar muito: https://github.com/celluloid/nio4r/wiki/Basic-Flow-Control. Reparem que é muito semelhante ao que já temos, inclusive as nomeclaturas.

## Mini Express
Tente fazer uma implementação que forneca uma API parecida com a do Express do Node. Por ora não precisa suportar parâmetros na URL.

## Rack interface
Nosso servidor HTTP pode ser usado numa aplicação Rack? Tente =]

## libuv
A libuv é a biblioteca por trás do Node, que abstrai bastante as camadas mais baixas de sistemas assíncronos.
Esse exercício é tentar manter a mesma API que propomos, mas utilizando por trás a libuv, através dos bindings de Ruby dela: https://github.com/cotag/libuv
Obs: não sei se é possível fazer esse exercício, mas se alguém estiver disposto a tentar...
