# http_ruby_benchmark

Simple benchmark script to measure the memory consumed and the request time of some HTTP client gems for Ruby.

## 📊 O que é?

Este projeto executa benchmarks comparativos de diferentes bibliotecas HTTP em Ruby, medindo:
- **Memória**: Total de memória alocada (em KB)
- **Alocações**: Número total de alocações de objetos
- **Tempo**: Tempo decorrido para executar as requisições

## 🎯 Cenários de Teste

Este projeto testa **3 cenários diferentes** para simular diferentes tipos de cargas reais:

| Cenário | Tamanho | Requisições | Caso de Uso |
|---------|---------|------------|-----------|
| **Light** | 1 KB | 50 | Testa overhead do cliente (APIs rápidas, low-latency) |
| **Normal** | 100 KB | 30 | Respostas médias (APIs típicas, padrão) |
| **Heavy** | 1 MB | 10 | Alto volume de dados (downloads, grandes respostas) |

Diferentes tamanhos revelam diferentes comportamentos:
- **Light**: CPU-bound, testa overhead do protocolo HTTP
- **Normal**: Caso de uso típico, equilíbrio entre CPU e I/O
- **Heavy**: I/O-bound, testa eficiência em transferências grandes

## 🚀 Como usar

### Com Docker (Recomendado)

```bash
docker build -t http-benchmark .

# Cenário padrão (normal - 100 KB)
docker run --rm http-benchmark

# Ou execute um cenário específico:
docker run --rm http-benchmark ruby benchmark.rb light    # 1 KB, 50 requisições
docker run --rm http-benchmark ruby benchmark.rb normal   # 100 KB, 30 requisições
docker run --rm http-benchmark ruby benchmark.rb heavy    # 1 MB, 10 requisições
```

### Localmente (requer Ruby 3.2+)

```bash
# Instalar dependências
bundle install

# Executar benchmark - cenário padrão
ruby benchmark.rb

# Ou execute um cenário específico:
ruby benchmark.rb light
ruby benchmark.rb normal
ruby benchmark.rb heavy
```

## 📈 Interpretando os resultados

Ao analisar os resultados:

- **Memória baixa + Tempo baixo** = Melhor opção geral ✅
- **Alocações altas** = Mais pressão no garbage collector (pior em produção)
- **Comparar entre cenários** = Veja como cada lib escala com diferentes payloads
- **Light vs Heavy** = Se performance muda muito, a lib é sensível ao tamanho de dados

<!-- benchmark-results -->

### HTTP RubyGems Benchmark - 2026-01-18
#### Consolidated Results (Light + Normal + Heavy)

**Light (1 KB)** (1 KB, 50 requisições)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1143 | 622 | 0.077 |
| Faraday | 1099 | 630 | 0.0662 |
| HTTParty | 1011 | 579 | 0.0724 |
| Typhoeus | 82 | 552 | 0.0644 |
| httpx | 1084 | 944 | 0.0678 |
| http.rb | 1159 | 1530 | 0.0874 |

**Normal (100 KB)** (100 KB, 30 requisições)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1402 | 632 | 0.0714 |
| Faraday | 1329 | 638 | 0.0691 |
| HTTParty | 1251 | 585 | 0.0694 |
| Typhoeus | 215 | 572 | 0.0652 |
| httpx | 421 | 1060 | 0.0723 |
| http.rb | 1191 | 2016 | 0.0866 |

**Heavy (1 MB)** (1024 KB, 10 requisições)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 4370 | 689 | 0.0827 |
| Faraday | 4160 | 701 | 0.0839 |
| HTTParty | 4156 | 645 | 0.0821 |
| Typhoeus | 1489 | 749 | 0.0701 |
| httpx | 2294 | 1698 | 0.0949 |
| http.rb | 1346 | 4444 | 0.1084 |

