## Contact Information

* Phone: (86) 173****7611
* Email: liuyehcf@gmail.com
* LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/in/yourprofile/)

---

## Education

**Beijing University of Posts and Telecommunications**

*  **Master, Telecommunications Engineering** | 2015.9-2018.4
*  **Bachelor, Telecommunications Engineering** | 2015.9-2018.4

---

## Experience

### Starrocks | Database internal developer | 2021.8 - Now

StarRocks is a next-gen, high-performance analytical data warehouse that enables real-time, multi-dimensional, and highly concurrent data analysis.

* **Vectorization engine refactoring**, aimed to achieve fine-grained resource control, improve resource utilization, and enhance concurrent performance.
   * Implement user-space scheduler.
   * Implement multiply operators, like aggregate/window function/scan/table function/exchange, etc.
* **Window function optimization**, aimed to improve the performance of window functions and reduced memory usage.
   * Design and implement a top-N based optimization approach that significantly improves performance by an order of magnitude.
* **Sort merge optimization**, aimed to eliminate the bottleneck caused by serial merging and improve the performance of the overall sorting process.
   * Design and implement parallelized merge algorithm, achieving a performance improvement of an order of magnitude.
* **Support certain types of subquery**, aimed to enhance the functionality of subqueries.

### Alibaba group | Software engineer | 2018.4 - 2021.8

* **Tunnel service**, aimed to enable users to access their own devices/services installed in a private network.
   * Design and implement this service from scratch. (Based on netty)
   * Implement a user-friendly proxy for HTTP(S) protocols that allows users to access local HTTP pages using any native browser.
   * Implement a user-friendly proxy for SSH/SFTP protocols that allows users to access local devices with an embedded SSH component within our service console.
   * Support all types of protocols that based on tcp with a user-side agent, which is a local proxy process listening at a particular port.
   * Support multiplexing.
* **Flow execution framework**, an efficient solution for executing interconnectivity rules for IoT devices.
   * Built upon my compilation framework, I have provided a comprehensive set of DSL descriptions.
   * Adopted an event-driven programming model and provided flexible secondary development interfaces such as aspects and listeners.
   * This framework is also my personal project, please refer to [flow-engine-README](https://github.com/liuyehcf/liuyehcf-framework/blob/master/flow-engine/README.md) for details.
* **Expression execution framework**, a framework that offers rich expression capabilities and efficient execution performance.
   * Built upon my compilation framework, I have provided interfaces for secondary development, including support for extending custom functions, operator overriding, and more.
   * This framework is also my personal project, please refer to [expression-engine-README](https://github.com/liuyehcf/liuyehcf-framework/blob/master/expression-engine/README.md) for details.
* **An all-in-one solution**, that offers out-of-the-box capabilities. Built on top of Kubernetes, it provides a comprehensive set of operational features, including device management, application management, fault diagnosis, and more.
   * Provided two sets of operating system image pipelines, including CentOS 7.6 and Unbuntu 18.04, facilitating rapid replication of production for device manufacturers.
   * Provided machine activation functionality for out-of-the-box setup.
   * Provided a diagnostic tool for troubleshooting various issues related to networking, containers, and other components within Kubernetes (K8s) environment.

---

## Skills

* Cpp, Java, Go
* Shell, Python, Perl

---

## References

* All pull requests of starrocks, [liuyehcf contributions to starrocks](https://github.com/StarRocks/starrocks/pulls?q=is%3Apr+is%3Aclosed+author%3Aliuyehcf). All the work details of my work experience at Starrocks can be found here.
* My personal projects, [liuyehcf-framework](https://github.com/liuyehcf/liuyehcf-framework/tree/master), including compilation framework, expression framework, flow framework.
