
# 1 Self Introduction

Nice to meet you! Thank you for taking the time to interview me. My name is Calvin, and I am from China. I obtained both my bachelor's and master's degrees from BUPT (Beijing University of Posts and Telecommunications), where I specialized in communication engineering. During my postgraduate studies, I began self-learning computer science to further broaden my skills.

Throughout my professional journey, I have had the privilege of working for two distinguished companies. The first company is Alibaba Group. During my time there, I was part of the IoT department, where our team focused on developing a platform for managing and facilitating various devices, such as smart home security systems and industrial sensors. Additionally, we aimed to facilitate industrial upgrading for diverse industries.

Following my experience at Alibaba Group, I joined a startup, which is widely recognized for its exceptional OALP (Open Analytics and Log Processing) database product in China, called StarRocks. This product stands out for its outstanding performance.

Once again, I'm delighted to meet you, and I am eager to discuss more during this interview.

# 2 Experience Questions

## 2.1 Tunnel Service

### 2.1.1 Introduction

The tunnel service is specifically designed to meet the demand for accessing private network devices through SSH and HTTP protocols. At our platform, we have seamlessly integrated these capabilities into our platform console, available at aliyun.com.

Tunnel service refers to an overlay network that operates above the TCP protocol, employing an asymmetric architecture. This design comprises three principal components: the tunnel server, user-side agent, and device-side agent. The tunnel server acts as a central hub, providing authentication and facilitating the communication between the user-side agent and the device-side agent. The device-side agent connects to the server and routes messages between the actual local service such as sshd and the server. On the other hand, the user-side agent connects to the server and handles message routing between the user and the server. 

In terms of usability, we have simplified the usage of the HTTP and SSH protocols. For SSH protocol, the user-side agent can be a terminal component embedded in our platform, providing the necessary functionality. And for HTTP protocol, any standard web browser can act as the agent, which is truly magical in terms of versatility and convenience. And for other protocol that based on tcp, user must run additional agent at his computer to listen and forward traffic.

For ease of implementation, we have adopted WebSocket as the underlying protocol on both the user-side and device-side. This choice allows for seamless communication and simplifies the integration process.

### 2.1.2 Details of the ssh proxy

The platform provides a convenient web terminal component for SSH/SFTP protocol, ensuring ease of use. This component transfers plain text to the server, which then wraps it using the SSH protocol and directs it to the device's 22 port within a private network.

### 2.1.3 Details of the http proxy

This approach relies on a premise that the majority of standard browsers include the original domain name in the HTTP header as `Host`. Whenever the user enables this feature, a temporary domain name is generated, consisting of an UUID as the first segment, which maps to a specific device information. As a result, the server can extract tunnel information from the Host property and precisely direct traffic to the corresponding destinations.

## 2.2 Flow Execution Framework

The second thing I've done is provide two important frameworks to facilitate the device rule center, which is built to offer efficient management of device linkage rules, such as automatically turning on the lights after the door is opened, and facilitating the generation of device warnings as well as message routing.

The first framework is the flow execution framework, an integral part of the device rule center, providing two critical functions. Firstly, it incorporates a flow DSL implemented using my own compiler project, which provides various statements, including 'if-else', 'join-then', 'select-then', 'sub-then', and supports both cascaded and parallelized link types. These statements support different node types such as actions, conditions, gateways, and subflows. Secondly, it features an event-driven execution engine, where each task executes its designated functions and generates subsequent tasks to progress the flow. Additionally, it includes features such as exception short-circuiting and execution profiling.

The second framework is the expression execution framework, a component of the flow execution framework that simplifies expression evaluation. It is built using my own compiler project, and supports various literals, operators, operator overloading, built-in functions, and user-defined functions, including both fixed and variable parameters.

## 2.3 Edge Gateway Device

The third project I participated in was an intelligent edge integrated machine, designed to support industrial applications and device connections. Its use cases span across residential communities, roadside parking, agriculture, industry and more. My primary responsibility is to build a pipeline for creating various customized operating system installation images(can be an iso file or just a rootfs). This image includes the original CentOS or Ubuntu system packages as well as all the necessary software and configurations required by our business. Additionally, I have designed and developed a troubleshooting tool, primarily focused on addressing network and Kubernetes (k8s) runtime environment issues.

## 2.4 Questions

1. How the tunnel service works?
    * It starts with the user opening the terminal at our console or navigating to another web page with a unique address.
    * Then the server send a NewSession packet to the corresponding device, if the specific port of the local device is available, then the session established.
    * Any actions from the user will be route to the device, and any message from the device's service will be route to the user.
1. How can the web broswer can be the user-side agent.
    * The web broser will set the originl host as the Host field in the http header. So by leveraging this property, the server can create a unique http address for a specific service of a particular user, the first segment of the address is an UUID, which can be resolved to its corresponding tunnel information, helps the server to direct the traffic to the correct edge device.
1. Device warnings
    * Device online/offline
    * Cpu/Memory/Disk
1. Message Routing
    * Offer more flexibility in routing message than the message middleware like kafka or rocketmq
1. Compile-engine
    * Lexical Analyzer
    * NFA (Non-Deterministic Finite Automaton) and DFA (Deterministic Finite Automaton)
    * Support several types of grammar analysis algorithm, like, LL1, LALR, LR1
1. How the operator overloading is achieved?
    * Each function description can map to a group of implementations, and each implementations has a priority. The implementation with higher proirity matches first.
1. What problems does the tool address?
    * CoreNDS
    * iptables-rules
1. Autoboxing
1. Image Pipeline
    * CentOS offers a image build tool called anaconda, providing a flexible configuration called kickstart for customized settings, incluing the network, disk config, account, and as well as script for more complex configurations.

## 2.5 Starrocks

I have been employed at Starrocks for the past two years. I was luckily involved in the fundamental re-design and re-implementation of the execution engine right after I joined the company. This refactor involves transitioning from a volcano execution model to a more efficient and flexible morsel-driven execution engine, where I was responsible for implementing several operators like aggregator, window function and table function.

My contributions at Starrocks have spanned both the execution engine and plan optimization, resulting in significant improvements to the system's performance and observability.

In terms of plan optimization, I enhanced the system's capabilities by incorporating various types of subqueries like join on subquery and scalar non-agg subquery, and efficiently refactored the subquery transformation process to achieve the optimization of constant removal. Additionally, I refactored a plan enumeration mechanism that allows for thorough testing of the efficiency of cost-based algorithm, ensuring optimal query execution plans.

As for execution, my focus was on optimizing the ranking window function, leading to an impressive 10x performance improvement. And I have designed and implemented a parallel merge operator(based on Merge Path algorithm) that delivered a remarkable 10x performance boost, effectively overcoming the bottlenecks associated with serial merge. Additionally, I have achieved many things, including introducing a sliding window technique to parallelize ordered data transformation, and addressing numerous performance issues such as reducing code cache misses and eliminating pointer aliases for SIMD optimizations.

For better observability and query analysis, I introduced support for runtime profiling and developed a profile analysis tool. This feature enables users to easily understand query bottlenecks and identify opportunities for optimization.

**Killing Features:**

1. MPP (Massively Parallel Processing) Distributed Execution
    * Performance & Resource Utilization
    * Scalability
1. Pipeline Parallel Execution Framework
1. Vectorized Execution
1. CBO (Cost-Based Optimizer) Optimization
1. Global Runtime Filter
1. Metadata Cache
1. Local Data Cache
1. Materialized View

## 2.6 Questions

1. Why are you refactoring the subquery transformation process?
    * In the previous process, the subquery would be transformed to ApplyOperator first, missing the opportunity to apply optimizations such as constant removal or predicate simplification
    * After this refactor, the subquery used as an expression will be temporarily held back until the expression optimizations are performed, allowing it to fully benefit from these optimizations
1. What's optimization can lead to 10 times performance boost of the ranking window function?
1. What's the advantages of the morsel-driven execution engine?
1. Subquery classification.

# 3 Database

1. What is OLAP (Online Analytical Processing) and how does it differ from OLTP (Online Transaction Processing)?
    > OLAP is a technology for data analysis, providing multidimensional views and complex queries. OLTP handles real-time transactional data processing for day-to-day operations.

1. What are the key differences between a relational database and an OLAP database?
    > Relational databases are designed for transactional processing, while OLAP databases are optimized for complex analytical queries and reporting.

1. Describe the process of building an OLAP database model from a relational database.
    > The process involves identifying requirements, extracting and transforming data, designing a multidimensional schema, building OLAP cubes, optimizing performance, and connecting with frontend tools for analysis.

1. How do you optimize query performance in an OLAP database?
    > Optimize query performance in an OLAP database by creating appropriate indexes, aggregating data, implementing efficient data storage strategies, partitioning large tables, using data compression, caching query results, and leveraging parallel processing capabilities.

1. What is the purpose of dimension hierarchies in OLAP systems? Provide an example.
    > The purpose of dimension hierarchies in OLAP systems is to organize data in a structured, hierarchical manner, allowing users to drill-down or roll-up data to various levels of granularity for in-depth analysis.

1. How many types of schema in an OLAP database?
    > Star Schema: Consists of a central fact table connected to multiple dimension tables in a single hierarchy, forming a star-like structure.
    > Snowflake Schema: Similar to the star schema, but dimension tables are normalized into multiple related tables, reducing data redundancy.
    > Constellation Schema (also known as Galaxy Schema): Contains multiple fact tables sharing dimension tables, offering more flexibility and support for diverse data models.

1. What are the advantages and disadvantages of using a star schema in an OLAP database?
    > Star schema provides simplified queries and faster performance in OLAP databases, but it may lead to higher storage requirements and data redundancy.

1. What are the advantages and disadvantages of using a snowflake schema in an OLAP database?
    > The advantages of using a snowflake schema in an OLAP database include reduced data redundancy, improved data integrity, and better space efficiency, but it may lead to more complex queries and potentially slower performance due to multiple joins.

1. What are the differences between a star schema and a constellation schema in an OLAP database?
    > In a star schema, there is a central fact table connected to dimension tables in a single hierarchy, whereas in a constellation schema, multiple fact tables share dimension tables, offering greater flexibility but possibly leading to increased complexity and performance trade-offs.

1. Can you discuss the role of metadata in an OLAP database system?
    > Metadata in an OLAP database system serves as essential data about data, facilitating data organization, query optimization, data understanding, security, ETL processes, versioning, and system administration.

## 3.1 Uncategorized

1. why map fast?
1. why there are multiply fragments in a query?
1. the difference between bitmap column and bitmap index?

# 4 Java

1. What is Java? Explain its key features.
    > Java is a versatile and secure programming language known for its platform independence, object-oriented approach, automatic memory management, and strong typing. It has a rich standard library, supports multithreading, and has robust security features. Java is widely used for diverse applications, including desktop software, web development, mobile apps, and enterprise systems.

1. What are the differences between JDK, JRE, and JVM?
    > In summary, JDK is a software package that provides tools for developing Java applications, JRE is a software package that provides the necessary runtime environment to execute Java applications, and JVM is a virtual machine that executes Java bytecode, allowing Java programs to run on any platform.

1. Explain the different types of memory in Java.
    > Java has different memory types: stack memory (for local variables and method calls), heap memory (for objects and dynamically allocated data), method area (for class-level information), program counter register (stores the address of the currently executing instruction), and native method stacks (for executing native code).

1. What are the main principles of object-oriented programming (OOP)?
    > OOP in Java uses classes and objects to encapsulate data and behavior. The main principles of object-oriented programming (OOP) are encapsulation, inheritance, and polymorphism, enabling modular and reusable code.

1. What is the difference between an abstract class and an interface in Java?
    > Same as C++

1. Explain the concept of method overloading and method overriding.
    > Method overloading refers to having multiple methods with the same name but different parameters within a class. Method overriding, on the other hand, occurs when a subclass modifies or extends a method inherited from its superclass.

1. What is the difference between checked and unchecked exceptions in Java?
    > Checked exceptions must be declared or handled, while unchecked exceptions can occur without explicit handling or declaration.

1. What are the access modifiers in Java? Explain their visibility levels.
    > Access modifiers in Java control visibility. "public" allows access anywhere, "protected" within the package and subclasses, "default" (no modifier) within the package, and "private" within the class.

1. What is the difference between ArrayList and LinkedList?
    > ArrayList provides fast random access using a dynamic array, while LinkedList offers efficient insertion and deletion using a doubly-linked list.

1. What is the difference between a constructor and a method?
    > Constructor initializes objects, called automatically when created, while a method performs actions, called explicitly by name.

1. What is the purpose of the "final" keyword in Java?
    > The "final" keyword in Java is used to indicate that a variable, method, or class cannot be modified or overridden, ensuring its immutability or preventing further extension.

1. How does garbage collection work in Java?
    > Garbage collection in Java automatically manages memory by identifying and reclaiming objects that are no longer referenced, freeing up resources and ensuring efficient memory usage without manual memory deallocation.

1. What is the difference between the "==" operator and the "equals()" method?
    > The "==" operator in Java compares the memory addresses of objects or the values of primitive types, while the "equals()" method compares the content or values of objects to determine if they are equivalent.

1. Explain the concept of multithreading in Java.
    > Multithreading in Java refers to the concurrent execution of multiple threads within a single program, allowing for improved efficiency by executing multiple tasks simultaneously and making effective use of available CPU resources.

1. What is the purpose of the "synchronized" keyword in Java?
    > The "synchronized" keyword in Java is used to ensure that only one thread at a time can access a critical section of code or an object, preventing concurrent access and maintaining thread safety in multi-threaded environments.

1. What is the difference between the "StringBuilder" and "StringBuffer" classes?
    > The main difference between the "StringBuilder" and "StringBuffer" classes is that "StringBuilder" is not thread-safe, while "StringBuffer" is thread-safe.

1. How does exception handling work in Java?
    > In Java, exceptions are handled using try-catch-finally blocks. Exceptions are caught and handled in catch blocks, and finally blocks are used for code that should always execute, regardless of whether an exception occurs, providing program stability.

1. What is the purpose of the "static" keyword in Java?
    > In Java, the "static" keyword is used to create class-level variables and methods that can be accessed without instantiating the class.

1. What is the difference between a shallow copy and a deep copy in Java?
    > Same as C++

1. Explain the concept of polymorphism in Java.
    > Polymorphism in Java allows objects of different classes to be treated as objects of a common superclass or interface, providing flexibility through method overriding and code reusability.

1. What is the difference between a static method and an instance method in Java?
    > Static methods belong to the class itself and can be accessed without creating an instance, while instance methods must be called through an instance.

1. What is the purpose of the "this" keyword in Java?
    > The "this" keyword in Java refers to the current instance of a class, distinguishing variables and accessing instance members.

1. What is the difference between a HashSet and a TreeSet in Java?
    > HashSet is an unordered collection using hashing, while TreeSet is a sorted collection with slower insertion and removal but providing ordered traversal.

1. Explain the concept of autoboxing and unboxing in Java.
    > Autoboxing is the automatic conversion of primitive types to their corresponding wrapper classes, while unboxing is the automatic conversion of wrapper class objects back to primitive types in Java.

1. What is the purpose of the "transient" keyword in Java?
    > The "transient" keyword in Java is used to indicate that a variable should not be serialized when an object is being converted into a stream of bytes, allowing for selective exclusion of variables from the serialization process.

1. Explain the concept of lambda expressions in Java.
    > Lambda expressions in Java are concise blocks of code that represent a functional interface and enable the use of functional programming paradigms.

1. What are the SOLID principles in object-oriented programming?
    > The SOLID principles are a set of five design principles in object-oriented programming:
    > 1. Single Responsibility Principle (SRP): A class should have only one reason to change.
    > 1. Open/Closed Principle (OCP): Software entities (classes, modules, functions, etc.) should be open for extension but closed for modification.
    > 1. Liskov Substitution Principle (LSP): Subtypes must be substitutable for their base types.
    > 1. Interface Segregation Principle (ISP): Clients should not be forced to depend on interfaces they do not use.
    > 1. Dependency Inversion Principle (DIP): High-level modules should not depend on low-level modules; both should depend on abstractions.
    > These principles collectively promote modular, extensible, and maintainable software design.

1. What is the purpose of the "super" keyword in Java?
    > The "super" keyword in Java is used to refer to the instance of parent class or superclass, allowing access to its instance members (methods, fields, constructors) and enabling method overriding and constructor chaining.

1. Explain the concept of anonymous classes in Java.
    > Anonymous classes in Java are unnamed local classes that are defined and instantiated simultaneously, often used for one-time implementations of interfaces or abstract classes.

1. What is the difference between a static variable and an instance variable in Java?
    > Static variables are shared among all instances of a class and belong to the class itself, while instance variables are unique to each object and belong to individual instances.

1. What is the purpose of the "volatile" keyword in Java?
    > The "volatile" keyword in Java ensures that a variable is always read from and written to the main memory, rather than a thread's local cache.

1. Explain the concept of inheritance in Java.
    > Same as Cpp

1. What is the difference between equals() and hashCode() methods?
    > equals() compares object contents for equality, while hashCode() returns an unique identifier for efficient hashing and storage in data structures.

1. Explain the concept of generics in Java.
    > Generics in Java enable the creation of classes and methods that can operate on different data types while providing type safety and code reusability through type parameters.

1. What is the purpose of the "throws" keyword in Java?
    > The "throws" keyword in Java indicates that a method may throw specific exceptions, requiring callers to handle or propagate them.

1. What are the different types of inner classes in Java?
    > The different types of inner classes in Java are static inner classes, non-static inner classes, local inner classes, and anonymous inner classes.

1. Explain the concept of method references in Java 8.
    > Method references in Java 8 provide a shorthand notation to refer to existing methods as lambda expressions, making code more concise and readable.

1. What is the difference between composition and inheritance in Java?
    > Composition emphasizes object collaboration through containment, while inheritance establishes a hierarchical "is-a" relationship for code reuse and specialization.

1. Explain the concept of functional interfaces in Java 8.
    > Functional interfaces in Java 8 are interfaces with a single abstract method, allowing lambda expressions and method references for concise expression of behavior.

1. Explain the concept of the Java Memory Model.
    > The Java Memory Model (JMM) defines how threads interact and access shared data, ensuring visibility and consistency through rules and synchronization mechanisms like locks and volatile variables.

1. What are the different types of collections in Java?
    > The different types of collections in Java include ArrayList, LinkedList, HashSet, TreeSet, HashMap, TreeMap, and more.

1. What is the difference between the "compareTo()" and "equals()" methods?
    > "compareTo()" is used for ordering objects based on their natural or customized order, while "equals()" is used to check for equality between objects based on their content.

1. Explain the concept of type erasure in Java generics.
    > Type erasure in Java generics is the process of removing type parameters and replacing them with their upper bounds or Object during compilation to maintain backward compatibility with pre-generic code.

1. How does serialization work in Java?
    > Serialization in Java converts objects into a byte stream for storage or transmission, while deserialization reconstructs objects from the byte stream.

1. What is the purpose of the "instanceof" operator in Java?
    > The "instanceof" operator in Java checks the type of an object, determining if it belongs to a specific class or implements a particular interface.

1. How can you handle concurrent modifications in Java collections?
    > Use synchronized collections or concurrent collections such as ConcurrentHashMap to handle concurrent modifications in Java.

1. What is the purpose of the "finalize()" method in Java? Is it recommended to use it?
    > "finalize()" is a method in Java used for object cleanup before destruction. It is not recommended for use due to its unreliable execution.

1. Explain the concept of method chaining in Java.
    > Method chaining in Java allows multiple methods to be invoked on an object in a single line, improving code readability and conciseness.

1. What are the different types of file I/O operations in Java?
    > The different types of file I/O operations in Java include character-based, byte-based, object-based, and random access I/O, catering to various data formats and manipulation requirements.

1. Explain the concept of static initialization blocks in Java.
    > Static initialization blocks in Java are used to initialize static variables or perform one-time setup tasks when a class is loaded into memory.

1. What is the purpose of the "ThreadLocal" class in Java?
1. How can you handle concurrent access in Java collections?
1. Explain the concept of the "compareTo()" method in the Comparable interface.
1. What is the purpose of the "getClass()" method in Java?
1. What are the different ways to create and start a thread in Java?
1. Explain the concept of method references in Java 8.
1. What is the purpose of the "Thread.sleep()" method in Java?
1. How does the "StringBuilder" class differ from the "String" class in Java?
1. Explain the concept of functional programming in Java.
1. What is the purpose of the "System.arraycopy()" method in Java?

# 5 Cpp

1. What is C++? Explain its key features.
    > C++ is an advanced programming language that combines the features of C with added capabilities for object-oriented programming. It offers high performance, a rich library, and strong compatibility with other languages.

1. What are the differences between C and C++?
    > C is procedural, while C++ supports procedural and object-oriented programming. C++ has features like classes, objects, and inheritance, along with the Standard Template Library. It also allows explicit memory management and has additional language features.

1. Explain the object-oriented programming (OOP) concepts in C++.
    > Same as Java

1. What is the difference between class and struct in C++?
    > In C++, the main difference between a class and a struct is that members are private by default in a class, while they are public by default in a struct.

1. Explain the concept of inheritance in C++.
    > In C++, inheritance allows a class to inherit properties and behaviors from another class, promoting code reuse and hierarchy among classes.

1. What is the difference between function overloading and function overriding in C++?
    > Same as Java

1. What are the access specifiers in C++? Explain their visibility levels.
    > Same as Java

1. What is the difference between new and malloc in C++?
    > new is an operator in C++ that invokes constructors, performs type checking, and returns a typed pointer, while malloc is a function in C that allocates raw memory and returns a void pointer.

1. Explain the concept of constructors and destructors in C++.
    > Constructors initialize objects during creation, while destructors clean up resources before object destruction in C++.

1. What are virtual functions in C++? How are they different from normal functions?
    > Virtual functions in C++ allow for dynamic binding and polymorphic behavior, enabling overridden versions in derived classes, while normal functions are resolved based on the static type at compile-time.

1. What is the difference between shallow copy and deep copy in C++?
    > In C++, a shallow copy creates a new object that references the same memory as the original, while a deep copy creates a new object with its own separate memory, duplicating the content of the original object to avoid shared references.

1. Explain the concept of templates in C++.
    > Templates in C++ allow for generic programming by defining functions or classes with placeholder types that can be instantiated with different actual types at compile time, enabling code reuse and flexibility in handling different data types without sacrificing performance.

1. What is the purpose of the "const" keyword in C++?
    > The "const" keyword in C++ declares read-only variables, parameters, or member functions, preventing modifications and ensuring code clarity and const-correctness.

1. What is the difference between pass by value and pass by reference in C++?
    > Pass by value in C++ creates a copy of the parameter, while pass by reference allows direct access to the original parameter, enabling modifications and avoiding unnecessary copies.

1. Explain the concept of exception handling in C++.
    > Same as Java

1. What is the purpose of the "static" keyword in C++?
    > The "static" keyword in C++ is used for static storage duration, defining class-level members, and limiting scope for global variables/functions.

1. Explain the concept of namespaces in C++.
    > Namespaces in C++ organize code elements to prevent naming conflicts by providing named scopes for variables, functions, and classes.

1. What is the difference between an abstract class and an interface in C++?
    > In C++, an abstract class can have both regular and pure virtual functions with member variables, while an interface contains only pure virtual functions and allows multiple inheritance.

1. What are the different types of storage classes in C++?
    > The different storage classes in C++ are "auto", "register", "static", "extern" and "thread_local".

1. What is the difference between reference and pointer in C++?
    > Pointers offer flexibility and direct memory access, while references provide simplicity and intuitive syntax by acting as aliases. References are implemented as constant pointers, abstracting away pointer operations.

1. Explain the concept of function pointers in C++.
    > Function pointers in C++ are variables that store the memory address of a function, providing a way to call functions dynamically and enabling callback mechanisms.

1. What are the different types of inheritance in C++?
    > C++ supports single, multiple, multilevel, hierarchical, and hybrid inheritance, allowing classes to inherit from one or more base classes.

1. Explain the concept of operator overloading in C++.
    > Operator overloading in C++ redefines operators for user-defined types, enabling custom behavior and allowing objects to be used with operators like + or <<.

1. What is the difference between static binding and dynamic binding in C++?
    > Static binding happens at compile-time, resolving function calls based on static types. Dynamic binding occurs at runtime, selecting functions based on dynamic types.

1. What are the different types of polymorphism in C++?
    > In C++, polymorphism can be achieved through compile-time polymorphism, which includes function overloading and template specialization, as well as runtime polymorphism, achieved through inheritance and virtual functions.

1. What is the purpose of the "this" pointer in C++?
    > Same as Java

1. Explain the concept of smart pointers in C++.
    > Smart pointers in C++ are objects that automatically manage memory through reference counters, preventing issues like memory leaks and dangling pointers. They include unique pointers, shared pointers, and weak pointers.

1. What are the different types of STL containers in C++?
    > The different types of STL containers in C++ include sequence containers (vector, list, deque, array, forward_list), ordered associative containers (set, multiset, map, multimap), and unordered associative containers (unordered_set, unordered_multiset, unordered_map, unordered_multimap).

1. What is the difference between vectors and arrays in C++?
    > Vectors in C++ provide dynamic size, automatic memory management, while arrays have a fixed size, require manual memory management.

1. Explain the concept of move semantics and rvalue references in C++.
    > Move semantics and rvalue references in C++ allow the efficient transfer of resources (like memory ownership) from one object to another, reducing unnecessary copying and improving performance, through the use of move constructors and move assignment operators.

1. What is the difference between const reference and rvalue reference in C++?
    > Const reference is a reference to a constant value used for read-only scenario without copying parameters, while an rvalue reference is used for efficient resource transfer, typically in move semantics.

1. What is the purpose of the "friend" keyword in C++?
    > The "friend" keyword in C++ grants non-member functions or classes privileged access to private and protected members of a class.

1. What is the difference between stack memory and heap memory in C++?
    > Stack memory is used for local variables and funciton calls and has automatic management, while heap memory is used for dynamic memory allocation and requires manual management using new and delete.

1. What is the purpose of the "auto" keyword in C++11?
    > The "auto" keyword in C++11 enables automatic type deduction for variables based on their initializer, enhancing code readability and reducing the need for explicit type declarations.

1. Explain the concept of lambda expressions in C++11.
    > Same as Java

1. What is the purpose of the "constexpr" keyword in C++?
    > The "constexpr" keyword in C++ allows compile-time evaluation, improving performance and enabling the use of compile-time constants.

1. Explain the concept of copy constructors in C++.
    > A copy constructor in C++ creates a new object by initializing it with the values of an existing object of the same class.

1. Explain the concept of function objects (functors) in C++.
    > In C++, function objects, also known as functors, are objects that can be invoked as if they were functions, allowing customization for flexible behavior.

1. Explain the concept of virtual destructors in C++.
    > A virtual destructor in C++ ensures that the destructor of the most derived class is called first when deleting an object through a base class pointer, allowing proper cleanup and preventing memory leaks.

1. What is the purpose of the "explicit" keyword in C++?
    > The "explicit" keyword in C++ is used to prevent implicit type conversions by specifying that a constructor or conversion function should only be used for explicit, direct initialization.

1. Explain the concept of multithreading in C++.
    > Same as Java

1. What is the purpose of the "volatile" keyword in C++?
    > The "volatile" keyword in C++ is used to indicate that a variable can be modified by external sources and prevents certain optimizations by the compiler, ensuring direct memory access.

1. Explain the concept of the Rule of Three (or Five) in C++.
    > The Rule of Three (or Five) in C++ suggests that if a class needs to define one of the special member functions (copy constructor, copy assignment operator, or destructor), it often needs to define all three (Rule of Three) or the additional two (move constructor and move assignment operator) for proper resource management and copying semantics.

1. Explain the concept of function binding in C++.
    > Function binding in C++ refers to the process of associating a function call with a specific function implementation or object, allowing it to be invoked at a later time.

1. What is the purpose of the "typeid" operator in C++?
    > The "typeid" operator retrieves the runtime type information of an object in C++.

1. What is the purpose of the "static_assert" keyword in C++11?
    > "static_assert" in C++11 performs compile-time checks, generating errors if conditions are not met.

1. Explain the concept of CRTP (Curiously Recurring Template Pattern) in C++.
    > CRTP (Curiously Recurring Template Pattern) in C++ is a design pattern where a base class template is derived from by a derived class, enabling the base class to access and manipulate properties and behavior of the derived class.

1. What is the purpose of the "decltype" keyword in C++?
    > The "decltype" keyword in C++ determines the type of an expression at compile time, used for template metaprogramming and type deduction.

1. Explain the concept of function overloading resolution in C++.
    > Function overloading resolution in C++ selects the best-matching function based on argument types, allowing multiple functions with the same name but different parameters.

1. Explain the concept of the Pimpl idiom in C++.
    > The Pimpl idiom in C++ separates the interface and implementation of a class, enhancing encapsulation and code modularity.

1. What is the purpose of the "constexpr" keyword in C++11?
1. Explain the concept of variadic templates in C++.
1. What is the difference between lvalue and rvalue in C++?
1. Explain the concept of perfect forwarding in C++.
1. What is the purpose of the "explicit" keyword for constructors in C++?
1. Explain the concept of the CRTP (Curiously Recurring Template Pattern) in C++.
1. What is the difference between the pre-increment and post-increment operators in C++?
1. Explain the concept of the stack unwinding in C++ exception handling.
1. What is the purpose of the "noexcept" specifier in C++?
1. Explain the concept of the RAII (Resource Acquisition Is Initialization) idiom in C++.
1. What is the difference between the "emplace_back" and "push_back" methods in C++ vector?
1. Explain the concept of the C++ Standard Library algorithms and iterators.

# 6 Network

1. What is a network? Explain the basic components of a network.
    > A network is a system of interconnected devices that enables communication and sharing of resources, consisting of nodes, links, and protocols.

1. What is the difference between a LAN and a WAN?
    > LANs are smaller networks that cover a limited area, like a building or campus, while WANs are larger networks that connect multiple LANs over larger geographical distances.

1. What are the layers of the OSI model? Briefly explain each layer.
    > The OSI model consists of the Physical, Data Link, Network, Transport, Session, Presentation, and Application layers, which respectively handle physical transmission, error-free data framing, logical addressing and routing, reliable data delivery, connection management, data translation and formatting, and network service access.

1. What is the difference between TCP and UDP? When would you use each one?
    > TCP is a reliable, connection-oriented protocol used for applications that require data integrity and order, while UDP is a faster, connectionless protocol suitable for real-time applications where speed is prioritized over reliability.

1. Explain the concept of IP addressing and subnetting.
    > IP addressing assigns unique numerical identifiers (IP addresses) to network devices, enabling communication, while subnetting divides a network into smaller subnetworks for better efficiency and IP address management.

1. What is a router? How does it work in a network?
    > A router is a network device that connects multiple devices within a network and forwards data packets between them based on their IP addresses, enabling communication between different networks.

1. What is the purpose of ARP (Address Resolution Protocol)?
    > ARP maps IP addresses to MAC addresses on a local network, enabling devices to communicate by finding the MAC address associated with a specific IP address.

1. Explain the difference between a hub, switch, and a router.
    > A hub broadcasts data to all devices, a switch selectively sends data to the intended recipient, and a router connects networks and directs traffic based on IP addresses.

1. What is the purpose of DNS (Domain Name System)?
    > DNS translates domain names to IP addresses, enabling users to access websites using human-readable names rather than numerical IP addresses.

1. What is DHCP (Dynamic Host Configuration Protocol)? How does it work?
    > DHCP assigns IP addresses automatically. Devices request an address, and the DHCP server provides one for configuration.

1. What is NAT (Network Address Translation)?
    > NAT (Network Address Translation) is a technique that allows multiple devices on a private network to share a single public IP address for internet communication, by translating their private IP addresses to the public IP address.

1. What is the purpose of SSL (Secure Sockets Layer) and TLS (Transport Layer Security)?
    > SSL and TLS are used to secure internet communication by encrypting data, ensuring confidentiality, integrity, and authentication, protecting against eavesdropping and unauthorized access.

1. What is a VLAN (Virtual Local Area Network)?
    > A VLAN is a virtual network that enables logical segmentation of a physical network, providing isolation, security, and flexibility by separating network traffic into distinct groups.

1. Explain the difference between IPv4 and IPv6.
    > IPv4 has 32-bit addresses, limited availability, and lacks built-in security. IPv6 has 128-bit addresses, abundant availability, improved security features, and simplified address configuration.

1. What is the purpose of ICMP (Internet Control Message Protocol)?
    > ICMP (Internet Control Message Protocol) is used for error reporting, diagnostic messages, and network troubleshooting, including tasks like ping requests and detecting network congestion.

1. What is the purpose of a proxy server?
    > A proxy server acts as an intermediary between clients and the internet, providing benefits such as privacy, caching, filtering, load balancing, monitoring, and bypassing restrictions.

1. Explain the concept of Quality of Service (QoS) in networking.
    > QoS (Quality of Service) in networking prioritizes and manages network traffic to meet performance requirements. It involves traffic classification, bandwidth allocation, and congestion management to ensure optimal delivery of important data packets.

1. What is the purpose of a subnet mask? How is it used in IP addressing?
    > A subnet mask is used to determine the network and host portions of an IP address. It helps divide a network into subnets and is used in conjunction with IP addressing for network communication and routing.

1. Explain the concept of MAC address and how it is used in networking.
    > A MAC address is a unique identifier assigned to a network interface card (NIC) and is used for data communication at the link layer of the OSI model, enabling devices to identify and communicate with each other on a local network.

1. What is the difference between a unicast, multicast, and broadcast address?
    > A unicast address is used to send data from one sender to one specific recipient, a multicast address is used to send data from one sender to a select group of recipients, and a broadcast address is used to send data from one sender to all devices on the network.

1. What is the purpose of a default gateway in a network?
    > The default gateway in a network serves as the access point or router that connects a local network to external networks, enabling devices within the network to communicate with devices outside the local network, such as devices on the internet.

1. What is the difference between a static IP address and a dynamic IP address?
    > Static IP addresses are manually assigned and remain fixed, while dynamic IP addresses are automatically assigned and can change over time.

1. Explain the concept of port numbers and their significance in networking.
    > Port numbers are identifiers used in networking to direct data to specific applications or services on a device, allowing multiple services to run concurrently.

1. Explain the concept of network latency and how it affects network performance.
    > Network latency is the delay in data transmission within a network, impacting performance and responsiveness.

1. What is the difference between HTTP and HTTPS?
    > HTTP is unsecured, while HTTPS is secured with encryption for safer data transmission.

1. Explain the concept of DNS (Domain Name System) caching and its benefits.
    > DNS caching stores recently accessed DNS information locally, improving network performance and website loading times.

1. Explain the difference between symmetric encryption and asymmetric encryption.
    > Symmetric encryption uses a single key for encryption and decryption, while asymmetric encryption uses a pair of keys (public and private) for enhanced security.

1. What is the purpose of a VPN (Virtual Private Network)?
    > A VPN (Virtual Private Network) provides secure and encrypted remote access to private networks over the internet.

1. Explain the concept of IPsec (Internet Protocol Security) and its components.
    > IPsec (Internet Protocol Security) is a network protocol suite that ensures secure communication by providing authentication, encryption, and key management for IP packets.

1. What is the difference between half-duplex and full-duplex communication?
    > Half-duplex communication allows data transmission in both directions but not simultaneously, while full-duplex communication enables simultaneous data transmission in both directions.

1. What is a DDoS (Distributed Denial of Service) attack? How can it be mitigated?
    > A DDoS (Distributed Denial of Service) attack aims to disrupt a network by overwhelming it with illegitimate traffic, and it can be mitigated through traffic filtering, rate limiting, and deploying DDoS protection measures.

1. What is the purpose of a MAC address table in a switch?
    > A MAC address table in a switch tracks MAC addresses to facilitate accurate forwarding of network traffic to the correct destinations.

1. Explain the concept of IP routing and how it determines the path of network packets.
    > IP routing determines the path of network packets by analyzing the destination IP address and using a routing table to select the best path for efficient packet forwarding across interconnected networks.

1. What is the difference between a public IP address and a private IP address?
    > Public IP addresses are unique and used to identify devices on the internet, while private IP addresses are used within private networks for local communication and require NAT to access the internet.

1. Explain the concept of network congestion and its impact on network performance.
    > Network congestion happens when excessive data overwhelms the network, causing performance issues such as increased latency, packet loss, and reduced throughput.

1. Explain the concept of network load balancing and its benefits.
    > Network load balancing distributes traffic across multiple servers or resources to optimize performance, improve scalability, and enhance availability.

1. What is the purpose of an IPsec VPN tunnel and how does it provide secure communication?
    > An IPsec VPN tunnel provides secure communication by encrypting data packets, ensuring confidentiality, integrity, and authentication during transmission over untrusted networks.

1. Explain the three-way handshake process in TCP.
    > Three-way handshake in TCP: SYN, SYN-ACK, ACK. Client sends SYN to server, server responds with SYN-ACK, client acknowledges with ACK. Connection established.

1. What are the different TCP header fields? Briefly explain their significance.
    > TCP header fields, such as Source/Destination Port, Sequence/Acknowledgment Number, Control Bits, Window Size, Checksum, Urgent Pointer, and Options, provide essential information for establishing and managing connections, sequencing data, controlling flow, and ensuring data integrity in reliable data transmission.

1. How does TCP ensure reliable data delivery?
    > TCP ensures reliable data delivery through sequence numbers, acknowledgment, checksum, retransmission, sliding window, flow control and congestion control.

1. What is flow control in TCP? How is it achieved?
    > Flow control in TCP manages data transmission rates by using the "Window Size" field in the header, preventing data overflow in the receiver's buffer and ensuring reliable data delivery.

1. What is congestion control in TCP? How does TCP handle network congestion?
    > Congestion control in TCP manages data flow to prevent network congestion. It uses techniques like slow start, congestion avoidance, fast retransmit, and recovery to regulate data transmission and ensure fair network resource utilization.

1. Explain the concept of sliding window protocol in TCP.
    > The sliding window protocol in TCP allows the sender to transmit multiple data packets before waiting for acknowledgment from the receiver, optimizing data flow and ensuring reliable transmission.

1. What is the purpose of sequence numbers and acknowledgment numbers in TCP?
    > Sequence numbers in TCP ensure the correct ordering of data segments, while acknowledgment numbers acknowledge the successful receipt of these segments, enabling reliable data transmission.

1. How does TCP handle out-of-order packets and packet loss?
    > TCP handles out-of-order packets by buffering them until missing packets arrive, then delivers them in order; for packet loss, TCP initiates retransmission through timeout mechanisms and selective acknowledgment (SACK) to recover lost data.

1. What is the TCP Maximum Segment Lifetime (MSL)?
    > The TCP Maximum Segment Lifetime (MSL) is the maximum time a TCP segment can exist in the network without being acknowledged, typically set to 2 minutes.

1. What is the maximum segment size (MSS) in TCP?
    > The Maximum Segment Size (MSS) in TCP is the maximum amount of data that can be carried in the payload of a single TCP segment.

1. Explain the concept of selective acknowledgment (SACK) in TCP.
    > SACK in TCP acknowledges specific out-of-order data, helping sender retransmit only missing segments, enhancing reliability and performance.

1. What is the Nagle's algorithm in TCP? How does it affect the transmission of small packets?
    > Nagle's algorithm in TCP delays small packet transmission by buffering them, reducing overhead and avoiding "silly window syndrome," but it may cause slight delays in transmitting small packets.

1. Explain the concept of TCP round-trip time (RTT) estimation and its significance in congestion control.
    > TCP Round-Trip Time (RTT) estimation measures packet travel time for acknowledgment, vital for TCP's timeout calculation, congestion control, and fast retransmission.

1. Explain the concept of TCP timestamp option and its role in congestion control.
1. Explain the concept of network sniffing and its implications on network security.

# 7 Others

1. serverless

# 8 Reference

* [cpp-interview](https://github.com/huihut/interview)
* [interview](https://github.com/Olshansk/interview)
* [Interview](https://github.com/apachecn/Interview)
