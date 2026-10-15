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

### HTTP RubyGems Benchmark - 2026-10-15
#### Consolidated Results (Light + Normal + Heavy)

**Light (1 KB)** (1 KB, 50 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1141 | 608 | 0.0464 |
| Faraday | 1099 | 627 | 0.0466 |
| HTTParty | 1052 | 576 | 0.0461 |
| Typhoeus | 82 | 552 | 0.0462 |
| httpx | 981 | 945 | 0.0491 |
| http.rb | 995 | 1529 | 0.062 |

**Normal (100 KB)** (100 KB, 30 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 1392 | 629 | 0.0583 |
| Faraday | 1322 | 637 | 0.0588 |
| HTTParty | 1315 | 584 | 0.0543 |
| Typhoeus | 214 | 571 | 0.0561 |
| httpx | 420 | 1055 | 0.0601 |
| http.rb | 1190 | 2016 | 0.0882 |

**Heavy (1 MB)** (1024 KB, 10 requests)

| Gem | Memory (KB) | Allocations | Time (s) |
|-----|-----------|------------|----------|
| Net::HTTP | 4397 | 690 | 0.0372 |
| Faraday | 4189 | 702 | 0.037 |
| HTTParty | 4180 | 645 | 0.0409 |
| Typhoeus | 1489 | 752 | 0.0369 |
| httpx | 2213 | 1723 | 0.0468 |
| http.rb | 1346 | 4449 | 0.0671 |

