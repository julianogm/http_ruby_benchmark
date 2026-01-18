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

## � Formatos de Relatório

O script gera automaticamente relatórios em múltiplos formatos:

- **`README.md`** - Histórico de resultados em markdown (atualizado automaticamente)
- **`benchmark_latest.json`** - Últimos resultados em JSON (formato estruturado, versionado)
- **`benchmark_results_YYYY-MM-DD.json`** - Histórico datado em JSON (um arquivo por execução)
- **`benchmark_latest.csv`** - Últimos resultados em CSV (para importar em Excel/Sheets, versionado)
- **`benchmark_results_YYYY-MM-DD.csv`** - Histórico datado em CSV (um arquivo por execução)

> **Nota**: Os arquivos `benchmark_latest.*` são versionados no Git e atualizado automaticamente pelo CI/CD. O histórico datado permite acompanhar performance ao longo do tempo.

### Exemplo de saída JSON

```json
{
  "timestamp": "2026-01-18T16:20:38+00:00",
  "date": "2026-01-18",
  "requests_per_gem": 10,
  "gems": [
    {
      "name": "Net::HTTP",
      "memory_kb": 1289,
      "allocations": 627,
      "time_seconds": 0.0662
    }
  ]
}
```

## 🔄 CI/CD Automático

Este projeto usa **GitHub Actions** para executar benchmarks automaticamente:

- **Schedule**: A cada 14 dias (pode ser customizado)
- **Manual**: Via `workflow_dispatch` (botão "Run workflow" no GitHub)
- **Resultados**: São commitados automaticamente no README.md
- **Artifacts**: Histórico de JSONs e CSVs guardado por 90 dias

### Como rodar manualmente

1. Vá para a aba **Actions** no GitHub
2. Selecione **HTTP Ruby Benchmark**
3. Clique em **Run workflow**

## 🔧 Configuração

Para ajustar o número de requisições por gem, edite a constante em `benchmark.rb`:

```ruby
REQUESTS_PER_GEM = 10  # Aumentar para mais precisão, diminuir para testes rápidos
```

Para alterar a frequência do benchmark automático, edite `.github/workflows/benchmark.yml`:

```yaml
schedule:
  - cron: "0 0 */14 * *"  # A cada 14 dias às 00:00 UTC
```

<!-- benchmark-results -->

### HTTP RubyGems Benchmark - 2026-01-18
#### Net::HTTP
Memory: 1297 KB <br />Allocations: 626 <br />Time: 0.0559 seconds 
#### Faraday
Memory: 1083 KB <br />Allocations: 630 <br />Time: 0.0537 seconds 
#### HTTParty
Memory: 978 KB <br />Allocations: 582 <br />Time: 0.0543 seconds 
#### Typhoeus
Memory: 247 KB <br />Allocations: 560 <br />Time: 0.0557 seconds 
#### httpx
Memory: 796 KB <br />Allocations: 966 <br />Time: 0.0581 seconds 
#### http.rb
Memory: 1346 KB <br />Allocations: 4450 <br />Time: 0.0983 seconds 
