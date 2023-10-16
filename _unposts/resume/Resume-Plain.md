# StarRocks

```
VECTORIZATION ENGINE REFACTORING, aimed to achieve fine-grained resource control, improve resource utilization, and enhance concurrent performance.
• Implement user-space scheduler.
• Implement multiply operators, like aggregate/window function/scan/table function/exchange, etc.

WINDOW FUNCTION OPTIMIZATION, aimed to improve the performance of window functions and reduced memory usage.
• Design and implement a top-N based optimization approach that significantly improves performance by an order of magnitude.
• Change blocking process mode to streaming process mode for better memory utilization.
• Introduce removable cumulative calculation for sliding window process.

SORT MERGE OPTIMIZATION, aimed to eliminate the bottleneck caused by serial merging and improve the performance of the overall sorting process.
• Design and implement parallelized merge operator(based on Merge Path Algorithm), achieving a performance improvement of an order of magnitude.

SUPPORT CERTAIN TYPES OF SUBQUERY, aimed to enhance the system's capabilities.
• Support join on subqueries and scalar non-agg subqueries.
• Refactor the subquery process to benefit from expression optimizations like constants removal and predicate simplification.

SUPPORT QUERY PROFILING, aimed to enhance intuitive query analysis.
• Support text-based profile analysis through mysql protocol.
• Support visualized profile analysis for the enterprise edition.

OTHER OPTIMIZATIONS
• Introduce sliding window mechanism to parallelize ordered data transformation
• Reduce code cache misses of template code for better performance.
• Eliminate pointer aliases for better SIMD optimizations.
• Implement several functions like approx_top_k.
```

# Alibaba Group

```
TUNNEL SERVICE, aimed to enable users to access their own devices/services installed in a private network.
• Design and implement this service from scratch. (Based on netty)
• Implement a user-friendly proxy for HTTP(S) protocols that allows users to access local HTTP pages using any native web browser.
• Implement a user-friendly proxy for SSH/SFTP protocols that allows users to access local devices with an embedded SSH component within our service console.
• Support all types of protocols that based on tcp with a user-side agent, which is a local proxy process listening at a particular port.
• Support multiplexing, there can be multiple sessions connecting to a single device, either for the same or different services.

FLOW EXECUTION FRAMEWORK, an efficient solution for executing interconnectivity rules for IoT devices.
• Built upon my compilation framework, I have provided a comprehensive set of DSL descriptions.
• Adopted an event-driven programming model and provided flexible secondary development interfaces such as aspects and listeners.
• This framework is also my personal project, please refer to (https://github.com/liuyehcf/liuyehcf-framework/blob/master/flow-engine/README.md) for details.

EXPRESSION EXECUTION FRAMEWORK, a framework that offers rich expression capabilities and efficient execution performance.
• Built upon my compilation framework, I have provided interfaces for secondary development, including support for extending custom functions, operator overriding, and more.
• This framework is also my personal project, please refer to (https://github.com/liuyehcf/liuyehcf-framework/blob/master/expression-engine/README.md) for details.

INTELLIGENT EDGE INTEGRATED MACHINE, aimed to support support industrial applications and device management.
```