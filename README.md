# http_ruby_benchmark

Simple benchmark script to measure the memory consumed and the request time of some HTTP client gems for Ruby.

## 📊 What is it?

This project executes comparative benchmarks of different HTTP libraries in Ruby, measuring:
- **Memory**: Total allocated memory (in KB)
- **Allocations**: Total number of object allocations
- **Time**: Elapsed time to execute requests

## 🎯 Test Scenarios

This project tests **3 different scenarios** to simulate different types of real-world loads:

| Scenario | Size | Requests | Use Case |
|----------|------|----------|----------|
| **Light** | 1 KB | 50 | Tests client overhead (fast APIs, low-latency) |
| **Normal** | 100 KB | 30 | Medium responses (typical APIs, standard) |
| **Heavy** | 1 MB | 10 | High data volume (downloads, large responses) |

Different payload sizes reveal different behaviors:
- **Light**: CPU-bound, tests HTTP protocol overhead
- **Normal**: Typical use case, balance between CPU and I/O
- **Heavy**: I/O-bound, tests efficiency in large transfers

## 🚀 How to use

### With Docker (Recommended)

```bash
docker build -t http-benchmark .

# Default scenario (normal - 100 KB)
docker run --rm http-benchmark

# Or run a specific scenario:
docker run --rm http-benchmark ruby benchmark.rb light    # 1 KB, 50 requests
docker run --rm http-benchmark ruby benchmark.rb normal   # 100 KB, 30 requests
docker run --rm http-benchmark ruby benchmark.rb heavy    # 1 MB, 10 requests
```

### Locally (requires Ruby 3.2+)

```bash
# Install dependencies
bundle install

# Run benchmark - default scenario
ruby benchmark.rb

# Or run a specific scenario:
ruby benchmark.rb light
ruby benchmark.rb normal
ruby benchmark.rb heavy
```

## 📈 Interpreting results

When analyzing the results:

- **Low memory + Low time** = Best overall option ✅
- **High allocations** = More pressure on garbage collector (worse in production)
- **Compare between scenarios** = See how each lib scales with different payloads
- **Light vs Heavy** = If performance changes a lot, the lib is sensitive to data size

<!-- benchmark-results -->

### HTTP RubyGems Benchmark - 2026-06-01
#### Consolidated Results (Light + Normal + Heavy)

**Light (1 KB)** (1 KB, 50 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1143 | 623 | 0.0566 |
| Faraday | 1099 | 630 | 0.0573 |
| HTTParty | 1073 | 578 | 0.0593 |
| Typhoeus | 82 | 552 | 0.0611 |
| httpx | 818 | 950 | 0.0656 |
| http.rb | 1159 | 1528 | 0.0909 |

**Normal (100 KB)** (100 KB, 30 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1391 | 617 | 0.0568 |
| Faraday | 1322 | 637 | 0.0575 |
| HTTParty | 1315 | 584 | 0.0572 |
| Typhoeus | 214 | 571 | 0.0564 |
| httpx | 420 | 1051 | 0.0615 |
| http.rb | 1190 | 2016 | 0.0834 |

**Heavy (1 MB)** (1024 KB, 10 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 4394 | 690 | 0.0645 |
| Faraday | 4187 | 702 | 0.0644 |
| HTTParty | 4187 | 646 | 0.0604 |
| Typhoeus | 1489 | 755 | 0.0652 |
| httpx | 2210 | 1726 | 0.0724 |
| http.rb | 1348 | 4456 | 0.1018 |

