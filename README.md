# http_ruby_benchmark

Simple benchmark script to measure the memory consumed and the request time of some HTTP client gems for Ruby.

## 📊 O que é?

Este projeto executa benchmarks comparativos de diferentes bibliotecas HTTP em Ruby, medindo:
- **Memória**: Total de memória alocada (em KB)
- **Alocações**: Número total de alocações de objetos
- **Tempo**: Tempo decorrido para executar as requisições

## 🚀 Como usar

### Com Docker (Recomendado)

```bash
docker build -t http-benchmark .
docker run --rm http-benchmark
```

### Localmente (requer Ruby 3.2+)

```bash
# Instalar dependências
bundle install

# Executar benchmark
ruby benchmark.rb
```

## 📈 Interpretando os resultados

Os resultados são adicionados automaticamente ao final deste arquivo, em ordem cronológica. 

- **Memoria baixa + Tempo baixo** = Melhor opção geral
- **Alocações altas** = Mais pressão no garbage collector
- **Cada execução faz 10 requisições** para resultados mais confiáveis

## 🔧 Configuração

Para ajustar o número de requisições por gem, edite a constante em `benchmark.rb`:

```ruby
REQUESTS_PER_GEM = 10  # Aumentar para mais precisão, diminuir para testes rápidos
```

<!-- benchmark-results -->

### HTTP RubyGems Benchmark - 2026-01-15
#### Net::HTTP
Memory: 3141 KB <br />Allocations: 677 <br />Time: 0.0583 seconds 
#### Faraday
Memory: 1112 KB <br />Allocations: 803 <br />Time: 0.0537 seconds 
#### HTTParty
Memory: 1082 KB <br />Allocations: 663 <br />Time: 0.0515 seconds 
#### Typhoeus
Memory: 2110 KB <br />Allocations: 726 <br />Time: 0.0583 seconds 
#### httpx
Memory: 1125 KB <br />Allocations: 1150 <br />Time: 0.0566 seconds 
#### http.rb
Memory: 3457 KB <br />Allocations: 37342 <br />Time: 0.2245 seconds 
