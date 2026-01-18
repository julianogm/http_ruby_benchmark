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

