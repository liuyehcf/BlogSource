## Contact Information

* Name: Chenfeng He
* Phone: (86) 173****7611
* Email: liuyehcf@gmail.com
* LinkedIn: [Profile](linkedin.com/in/chenfeng-he-54525224a)
* Location: Hangzhou, Zhejiang, China

---

## Education

**Beijing University of Posts and Telecommunications**

*  **Master, Telecommunications Engineering** | 2015.9-2018.4
*  **Bachelor, Telecommunications Engineering** | 2011.9-2015.7

---

## Experience

### Starrocks | Database internal developer | 2021.8 - Now

StarRocks is a next-gen, high-performance analytical data warehouse that enables real-time, multi-dimensional, and highly concurrent data analysis.

* **Execution engine refactoring**, aimed to achieve fine-grained resource control, improve resource utilization, and enhance concurrent performance.
   * From volcano execution model to morsel-driven execution model.
   * Implement user-space scheduler.
   * Implement multiply operators, like aggregate/window function/scan/table function/exchange, etc.
* **Window function optimization**, aimed to improve the performance of window functions and reduced memory usage.
   * Design and implement a top-N based optimization approach that significantly improves performance by an order of magnitude.
   * Change blocking process mode to streaming process mode for better memory utilization.
   * Introduce removable cumulative calculation for sliding window process.
* **Sort merge optimization**, aimed to eliminate the bottleneck caused by serial merging and improve the performance of the overall sorting process.
   * Design and implement parallelized merge operator(based on Merge Path Algorithm), achieving a performance improvement of an order of magnitude.
* **Support certain types of subquery**, aimed to enhance the system's capabilities.
   * Support join on subqueries and scalar non-agg subqueries.
   * Refactor the subquery process to benefit from expression optimizations like constants removal and predicate simplification.
* **Support query profiling**, aimed to enhance intuitive query analysis.
   * Support text-based profile analysis through mysql protocol.
   * Support visualized profile analysis for the enterprise edition.
* **Other optimizations**
   * Introduce sliding window mechanism to parallelize ordered data transformation.
   * Reduce code cache misses of template code for better performance.
   * Eliminate pointer aliases for better SIMD optimizations.
   * Implement several functions like approx_top_k.

### Alibaba group | Software engineer | 2018.4 - 2021.8

* **Tunnel service**, aimed to enable users to access their own devices/services installed in a private network.
   * Design and implement this service from scratch. (Based on netty)
   * Implement a user-friendly proxy for HTTP(S) protocols that allows users to access local HTTP pages using any native web browser.
   * Implement a user-friendly proxy for SSH/SFTP protocols that allows users to access local devices with an embedded SSH component within our service console.
   * Support all types of protocols that based on tcp with a user-side agent, which is a local proxy process listening at a particular port.
   * Support multiplexing, there can be multiple sessions connecting to a single device, either for the same or different services.
* **Device Rule Center**, aimed to provide efficient management for device linkage rules.
   * **Flow execution framework**, an efficient solution for executing interconnectivity rules for IoT devices.
      * Built upon my compilation framework, I have provided a comprehensive set of DSL descriptions.
      * Adopted an event-driven programming model and provided flexible secondary development interfaces such as aspects and listeners.
      * This framework is also my personal project, please refer to [flow-engine-README](https://github.com/liuyehcf/liuyehcf-framework/blob/master/flow-engine/README.md) for details.
   * **Expression execution framework**, a framework that offers rich expression capabilities and efficient execution performance.
      * Built upon my compilation framework, I have provided interfaces for secondary development, including support for extending custom functions, operator overriding, and more.
      * This framework is also my personal project, please refer to [expression-engine-README](https://github.com/liuyehcf/liuyehcf-framework/blob/master/expression-engine/README.md) for details.
* **Intelligent Edge Integrated Machine**, aimed to support support industrial applications and device management.
   * Build a pipeline for creating various customized operating system installation images.
   * Develop a troubleshooting tool for addressing network and kubernetes runtime environment issues.

---

## Skills

* Cpp, Java, Go
* Shell, Python, Perl
* SQL

---

## Reference

* All pull requests of starrocks, [liuyehcf contributions to starrocks](https://github.com/StarRocks/starrocks/pulls?q=is%3Apr+is%3Aclosed+author%3Aliuyehcf). All the work details of my work experience at Starrocks can be found here.
   * [parallel merge algorithm](https://github.com/StarRocks/starrocks/pulls?q=is%3Apr+is%3Aclosed+author%3Aliuyehcf+parallel+merge)
   * [rank window function optimization](https://github.com/StarRocks/starrocks/pulls?q=is%3Apr+is%3Aclosed+author%3Aliuyehcf+rank+window+function)
   * [subquery related](https://github.com/StarRocks/starrocks/pulls?q=is%3Apr+is%3Aclosed+author%3Aliuyehcf+subquery)
* My personal projects, [liuyehcf-framework](https://github.com/liuyehcf/liuyehcf-framework/tree/master), including compilation framework, expression framework, flow framework.

