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

### HTTP RubyGems Benchmark - 2026-01-18
#### Consolidated Results (Light + Normal + Heavy)

**Light (1 KB)** (1 KB, 50 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1142 | 621 | 0.0539 |
| Faraday | 1098 | 623 | 0.0536 |
| HTTParty | 622 | 578 | 0.0539 |
| Typhoeus | 82 | 552 | 0.054 |
| httpx | 1023 | 951 | 0.0571 |
| http.rb | 1159 | 1530 | 0.0826 |

**Normal (100 KB)** (100 KB, 30 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1392 | 630 | 0.052 |
| Faraday | 1322 | 637 | 0.0532 |
| HTTParty | 1315 | 585 | 0.0527 |
| Typhoeus | 214 | 571 | 0.052 |
| httpx | 420 | 1059 | 0.0559 |
| http.rb | 1190 | 2017 | 0.0761 |

**Heavy (1 MB)** (1024 KB, 10 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 4376 | 689 | 0.0658 |
| Faraday | 4169 | 701 | 0.0648 |
| HTTParty | 4166 | 644 | 0.0642 |
| Typhoeus | 1489 | 749 | 0.0655 |
| httpx | 2286 | 1702 | 0.0736 |
| http.rb | 1348 | 4455 | 0.1006 |

