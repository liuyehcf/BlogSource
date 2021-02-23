---
title: Spring-Boot-源码剖析
date: 2018-08-26 09:38:19
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

**阅读更多**

<!--more-->

# 1 Normal

**分析起点是`SpringApplication.run`方法**

```java
public ConfigurableApplicationContext run(String... args) {
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        ConfigurableApplicationContext context = null;
        Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
        
        // 设置环境变量 java.awt.headless
        configureHeadlessProperty();

        // 创建监听器
        SpringApplicationRunListeners listeners = getRunListeners(args);

        // 调用监听器的 starting 方法
        listeners.starting();

        try {
            // 封装入参
            ApplicationArguments applicationArguments = new DefaultApplicationArguments(
                    args);

            // 封装environment
            ConfigurableEnvironment environment = prepareEnvironment(listeners,
                    applicationArguments);

            // 设置环境变量 spring.beaninfo.ignore
            configureIgnoreBeanInfo(environment);

            // 打印banner
            Banner printedBanner = printBanner(environment);

            // 根据 webApplicationType 创建 ConfigurableApplicationContext 的实例
            context = createApplicationContext();

            // 获取exceptionReporters
            exceptionReporters = getSpringFactoriesInstances(
                    SpringBootExceptionReporter.class,
                    new Class[] { ConfigurableApplicationContext.class }, context);

            // 一些预备工作，重点分析
            prepareContext(context, environment, listeners, applicationArguments,
                    printedBanner);
            
            // 经典的Spring refresh方法，重点分析
            refreshContext(context);

            // 一些收尾工作，重点分析
            afterRefresh(context, applicationArguments);

            stopWatch.stop();
            if (this.logStartupInfo) {
                new StartupInfoLogger(this.mainApplicationClass)
                        .logStarted(getApplicationLog(), stopWatch);
            }

            // 调用监听器的 started 方法
            listeners.started(context);

            // 调用runner
            callRunners(context, applicationArguments);
        }
        catch (Throwable ex) {
            handleRunFailure(context, ex, exceptionReporters, listeners);
            throw new IllegalStateException(ex);
        }

        try {
            // 调用监听器的 running 方法
            listeners.running(context);
        }
        catch (Throwable ex) {
            handleRunFailure(context, ex, exceptionReporters, null);
            throw new IllegalStateException(ex);
        }
        return context;
    }
```

## 1.1 prepareContext

```java
    private void prepareContext(ConfigurableApplicationContext context,
            ConfigurableEnvironment environment, SpringApplicationRunListeners listeners,
            ApplicationArguments applicationArguments, Banner printedBanner) {
        context.setEnvironment(environment);
        postProcessApplicationContext(context);
        // 调用初始化器的initialize方法
        applyInitializers(context);
        listeners.contextPrepared(context);
        if (this.logStartupInfo) {
            logStartupInfo(context.getParent() == null);
            logStartupProfileInfo(context);
        }

        // Add boot specific singleton beans
        context.getBeanFactory().registerSingleton("springApplicationArguments",
                applicationArguments);
        if (printedBanner != null) {
            context.getBeanFactory().registerSingleton("springBootBanner", printedBanner);
        }

        // Load the sources
        Set<Object> sources = getAllSources();
        Assert.notEmpty(sources, "Sources must not be empty");
        load(context, sources.toArray(new Object[0]));
        listeners.contextLoaded(context);
    }
```

## 1.2 refreshContext

# 2 Test

## 2.1 SpringJUnit4ClassRunner的初始化过程

**分析启动从`SpringJUnit4ClassRunner`类的创建开始**

1. 沿着继承链路调用父类构造方法，最终创建了一个`TestClass`对象
1. 创建一个`TestContextManager`对象

```java
    public SpringJUnit4ClassRunner(Class<?> clazz) throws InitializationError {
        // 创建TestClass对象
        super(clazz);
        if (logger.isDebugEnabled()) {
            logger.debug("SpringJUnit4ClassRunner constructor called with [" + clazz + "]");
        }
        ensureSpringRulesAreNotPresent(clazz);

        // 创建TestContextManager对象
        this.testContextManager = createTestContextManager(clazz);
    }
```

### 2.1.1 TestClass对象创建

**沿着继承链路调用父类构造方法，最终创建了一个`TestClass`对象**

```java
    public BlockJUnit4ClassRunner(Class<?> klass) throws InitializationError {
        super(klass);
    }

    protected ParentRunner(Class<?> testClass) throws InitializationError {
        this.testClass = createTestClass(testClass);
        validate();
    }

    public class TestClass implements Annotatable {
        ...
        private final Class<?> clazz;
        private final Map<Class<? extends Annotation>, List<FrameworkMethod>> methodsForAnnotations;
        private final Map<Class<? extends Annotation>, List<FrameworkField>> fieldsForAnnotations;
        ...
    }
```

### 2.1.2 TestContextManager

创建一个`TestContextManager`对象

1. 创建`BootStrap`上下文信息
1. 解析`BootStrap`上下文信息
1. 创建`TestContext`
1. 注册`Test`监听器

```java
    protected TestContextManager createTestContextManager(Class<?> clazz) {
        return new TestContextManager(clazz);
    }

    public TestContextManager(Class<?> testClass) {
        this(BootstrapUtils.resolveTestContextBootstrapper(BootstrapUtils.createBootstrapContext(testClass)));
    }

    public TestContextManager(TestContextBootstrapper testContextBootstrapper) {
        this.testContext = testContextBootstrapper.buildTestContext();
        registerTestExecutionListeners(testContextBootstrapper.getTestExecutionListeners());
    }
```

**创建`TestContext`，根据是否包含`@ContextHierarchy`，`@ContextConfiguration`这两个注解，创建Context的配置信息**

1. **不含有上述两个注解，即`Context`有且仅有一个**
1. **含有`@ContextHierarchy`注解，即`Context`可能有多个不同的层级，且每个层级可能有多个`Context`**
1. **仅含有`@ContextConfiguration`注解，`Context`的层级有且仅有一个，但是`Context`可能有多个**
* 上述三种情况，最终都会调用`AbstractTestContextBootstrapper.buildMergedContextConfiguration`方法

```java
    public TestContext buildTestContext() {
        // 创建Context
        TestContext context = super.buildTestContext();
        verifyConfiguration(context.getTestClass());
        WebEnvironment webEnvironment = getWebEnvironment(context.getTestClass());
        if (webEnvironment == WebEnvironment.MOCK
                && deduceWebApplicationType() == WebApplicationType.SERVLET) {
            context.setAttribute(ACTIVATE_SERVLET_LISTENER, true);
        }
        else if (webEnvironment != null && webEnvironment.isEmbedded()) {
            context.setAttribute(ACTIVATE_SERVLET_LISTENER, false);
        }
        return context;
    }

    public TestContext buildTestContext() {
        return new DefaultTestContext(getBootstrapContext().getTestClass(), buildMergedContextConfiguration(),
                getCacheAwareContextLoaderDelegate());
    }

    public final MergedContextConfiguration buildMergedContextConfiguration() {
        Class<?> testClass = getBootstrapContext().getTestClass();
        CacheAwareContextLoaderDelegate cacheAwareContextLoaderDelegate = getCacheAwareContextLoaderDelegate();

        // 如果不包含ContextHierarchy，ContextConfiguration这两个注解，说明Context有且仅有一个
        if (MetaAnnotationUtils.findAnnotationDescriptorForTypes(
                testClass, ContextConfiguration.class, ContextHierarchy.class) == null) {
            return buildDefaultMergedContextConfiguration(testClass, cacheAwareContextLoaderDelegate);
        }

        // 如果标记了ContextHierarchy注解，则需要维护Context的层级关系，并且合并成一个config对象
        if (AnnotationUtils.findAnnotation(testClass, ContextHierarchy.class) != null) {
            // 解析出ContextHierarchy包含的各个Context的层级关系
            // hierarchyMap是一个LinkedHashMap，前面的Context与后面的Context是 子-父 关系
            Map<String, List<ContextConfigurationAttributes>> hierarchyMap =
                    ContextLoaderUtils.buildContextHierarchyMap(testClass);
            MergedContextConfiguration parentConfig = null;
            MergedContextConfiguration mergedConfig = null;

            for (List<ContextConfigurationAttributes> list : hierarchyMap.values()) {
                List<ContextConfigurationAttributes> reversedList = new ArrayList<>(list);
                Collections.reverse(reversedList);

                // Don't use the supplied testClass; instead ensure that we are
                // building the MCC for the actual test class that declared the
                // configuration for the current level in the context hierarchy.
                Assert.notEmpty(reversedList, "ContextConfigurationAttributes list must not be empty");
                Class<?> declaringClass = reversedList.get(0).getDeclaringClass();

                mergedConfig = buildMergedContextConfiguration(
                        declaringClass, reversedList, parentConfig, cacheAwareContextLoaderDelegate, true);
                parentConfig = mergedConfig;
            }

            // Return the last level in the context hierarchy
            Assert.state(mergedConfig != null, "No merged context configuration");
            return mergedConfig;
        }
        else {
            // 创建包含一个层级，多个Context的Config对象
            return buildMergedContextConfiguration(testClass,
                    ContextLoaderUtils.resolveContextConfigurationAttributes(testClass),
                    null, cacheAwareContextLoaderDelegate, true);
        }
    }

    private MergedContextConfiguration buildMergedContextConfiguration(Class<?> testClass,
            List<ContextConfigurationAttributes> configAttributesList, @Nullable MergedContextConfiguration parentConfig,
            CacheAwareContextLoaderDelegate cacheAwareContextLoaderDelegate,
            boolean requireLocationsClassesOrInitializers) {

        Assert.notEmpty(configAttributesList, "ContextConfigurationAttributes list must not be null or empty");

        ContextLoader contextLoader = resolveContextLoader(testClass, configAttributesList);
        List<String> locations = new ArrayList<>();
        List<Class<?>> classes = new ArrayList<>();
        List<Class<?>> initializers = new ArrayList<>();

        for (ContextConfigurationAttributes configAttributes : configAttributesList) {
            if (logger.isTraceEnabled()) {
                logger.trace(String.format("Processing locations and classes for context configuration attributes %s",
                        configAttributes));
            }
            if (contextLoader instanceof SmartContextLoader) {
                SmartContextLoader smartContextLoader = (SmartContextLoader) contextLoader;
                smartContextLoader.processContextConfiguration(configAttributes);
                locations.addAll(0, Arrays.asList(configAttributes.getLocations()));
                classes.addAll(0, Arrays.asList(configAttributes.getClasses()));
            }
            else {
                String[] processedLocations = contextLoader.processLocations(
                        configAttributes.getDeclaringClass(), configAttributes.getLocations());
                locations.addAll(0, Arrays.asList(processedLocations));
                // Legacy ContextLoaders don't know how to process classes
            }
            initializers.addAll(0, Arrays.asList(configAttributes.getInitializers()));
            if (!configAttributes.isInheritLocations()) {
                break;
            }
        }

        Set<ContextCustomizer> contextCustomizers = getContextCustomizers(testClass,
                Collections.unmodifiableList(configAttributesList));

        Assert.state(!(requireLocationsClassesOrInitializers &&
                areAllEmpty(locations, classes, initializers, contextCustomizers)), () -> String.format(
                "%s was unable to detect defaults, and no ApplicationContextInitializers " +
                "or ContextCustomizers were declared for context configuration attributes %s",
                contextLoader.getClass().getSimpleName(), configAttributesList));

        MergedTestPropertySources mergedTestPropertySources =
                TestPropertySourceUtils.buildMergedTestPropertySources(testClass);
        MergedContextConfiguration mergedConfig = new MergedContextConfiguration(testClass,
                StringUtils.toStringArray(locations), ClassUtils.toClassArray(classes),
                ApplicationContextInitializerUtils.resolveInitializerClasses(configAttributesList),
                ActiveProfilesUtils.resolveActiveProfiles(testClass),
                mergedTestPropertySources.getLocations(),
                mergedTestPropertySources.getProperties(),
                contextCustomizers, contextLoader, cacheAwareContextLoaderDelegate, parentConfig);

        return processMergedContextConfiguration(mergedConfig);
    }
```

**注册Test监听器，找到`TestExecutionListener`的所有实现类，一共有8个，分别是**

1. **`MockitoTestExecutionListener`**
1. **`ResetMocksTestExecutionListener`**
1. **`TransactionalTestExecutionListener`**
1. **`AbstractDirtiesContextTestExecutionListener`**
1. **`DirtiesContextBeforeModesTestExecutionListener`**
1. **`DirtiesContextTestExecutionListener`**
1. **`ServletTestExecutionListener`**
1. **`DependencyInjectionTestExecutionListener`**
1. **`SqlScriptsTestExecutionListener`**
* 监听器是否启用，需要看测试类是否进行了相关的配置。例如，加了`@Transactional`注解后，该监听器才会触发

```java
    public final List<TestExecutionListener> getTestExecutionListeners() {
        Class<?> clazz = getBootstrapContext().getTestClass();
        Class<TestExecutionListeners> annotationType = TestExecutionListeners.class;
        List<Class<? extends TestExecutionListener>> classesList = new ArrayList<>();
        boolean usingDefaults = false;

        AnnotationDescriptor<TestExecutionListeners> descriptor =
                MetaAnnotationUtils.findAnnotationDescriptor(clazz, annotationType);

        // Use defaults?
        if (descriptor == null) {
            if (logger.isDebugEnabled()) {
                logger.debug(String.format("@TestExecutionListeners is not present for class [%s]: using defaults.",
                        clazz.getName()));
            }
            usingDefaults = true;
            // 获取默认的监听器
            classesList.addAll(getDefaultTestExecutionListenerClasses());
        }
        else {
            // Traverse the class hierarchy...
            while (descriptor != null) {
                Class<?> declaringClass = descriptor.getDeclaringClass();
                TestExecutionListeners testExecutionListeners = descriptor.synthesizeAnnotation();
                if (logger.isTraceEnabled()) {
                    logger.trace(String.format("Retrieved @TestExecutionListeners [%s] for declaring class [%s].",
                            testExecutionListeners, declaringClass.getName()));
                }

                boolean inheritListeners = testExecutionListeners.inheritListeners();
                AnnotationDescriptor<TestExecutionListeners> superDescriptor =
                        MetaAnnotationUtils.findAnnotationDescriptor(
                                descriptor.getRootDeclaringClass().getSuperclass(), annotationType);

                // If there are no listeners to inherit, we might need to merge the
                // locally declared listeners with the defaults.
                if ((!inheritListeners || superDescriptor == null) &&
                        testExecutionListeners.mergeMode() == MergeMode.MERGE_WITH_DEFAULTS) {
                    if (logger.isDebugEnabled()) {
                        logger.debug(String.format("Merging default listeners with listeners configured via " +
                                "@TestExecutionListeners for class [%s].", descriptor.getRootDeclaringClass().getName()));
                    }
                    usingDefaults = true;
                    classesList.addAll(getDefaultTestExecutionListenerClasses());
                }

                classesList.addAll(0, Arrays.asList(testExecutionListeners.listeners()));

                descriptor = (inheritListeners ? superDescriptor : null);
            }
        }

        Collection<Class<? extends TestExecutionListener>> classesToUse = classesList;
        // Remove possible duplicates if we loaded default listeners.
        if (usingDefaults) {
            classesToUse = new LinkedHashSet<>(classesList);
        }

        List<TestExecutionListener> listeners = instantiateListeners(classesToUse);
        // Sort by Ordered/@Order if we loaded default listeners.
        if (usingDefaults) {
            AnnotationAwareOrderComparator.sort(listeners);
        }

        if (logger.isInfoEnabled()) {
            logger.info("Using TestExecutionListeners: " + listeners);
        }
        return listeners;
    }

    protected Set<Class<? extends TestExecutionListener>> getDefaultTestExecutionListenerClasses() {
        Set<Class<? extends TestExecutionListener>> defaultListenerClasses = new LinkedHashSet<>();
        ClassLoader cl = getClass().getClassLoader();
        for (String className : getDefaultTestExecutionListenerClassNames()) {
            try {
                defaultListenerClasses.add((Class<? extends TestExecutionListener>) ClassUtils.forName(className, cl));
            }
            catch (Throwable ex) {
                if (logger.isDebugEnabled()) {
                    logger.debug("Could not load default TestExecutionListener class [" + className +
                            "]. Specify custom listener classes or make the default listener classes available.", ex);
                }
            }
        }
        return defaultListenerClasses;
    }

    protected List<String> getDefaultTestExecutionListenerClassNames() {
        // 找出所有TestExecutionListener的实现类作为默认的监听器
        List<String> classNames =
                SpringFactoriesLoader.loadFactoryNames(TestExecutionListener.class, getClass().getClassLoader());
        if (logger.isInfoEnabled()) {
            logger.info(String.format("Loaded default TestExecutionListener class names from location [%s]: %s",
                    SpringFactoriesLoader.FACTORIES_RESOURCE_LOCATION, classNames));
        }
        return Collections.unmodifiableList(classNames);
    }
```

## 2.2 SpringJUnit4ClassRunner.run

**分析起点，`SpringJUnit4ClassRunner.run`**

```java
    public void run(RunNotifier notifier) {
        if (!ProfileValueUtils.isTestEnabledInThisEnvironment(getTestClass().getJavaClass())) {
            notifier.fireTestIgnored(getDescription());
            return;
        }
        // 继续追踪
        super.run(notifier);
    }
```

**继续追踪，`ParentRunner.run`**

```java
    public void run(final RunNotifier notifier) {
        EachTestNotifier testNotifier = new EachTestNotifier(notifier,
                getDescription());
        try {
            Statement statement = classBlock(notifier);
            // 继续追踪
            statement.evaluate();
        } catch (AssumptionViolatedException e) {
            testNotifier.addFailedAssumption(e);
        } catch (StoppedByUserException e) {
            throw e;
        } catch (Throwable e) {
            testNotifier.addFailure(e);
        }
    }
```

**继续追踪，`RunAfterTestClassCallbacks.evaluate`**

```java
    public void evaluate() throws Throwable {
        List<Throwable> errors = new ArrayList<>();
        try {
            // 继续追踪
            this.next.evaluate();
        }
        catch (Throwable ex) {
            errors.add(ex);
        }

        try {
            this.testContextManager.afterTestClass();
        }
        catch (Throwable ex) {
            errors.add(ex);
        }

        MultipleFailureException.assertEmpty(errors);
    }
```

**继续追踪，`RunBeforeTestClassCallbacks.evaluate`**

1. 触发监听器的`TestExecutionListener.beforeTestClass`方法

```java
    public void evaluate() throws Throwable {
        // 触发监听器的beforeTestClass方法
        this.testContextManager.beforeTestClass();
        // 继续追踪
        this.next.evaluate();
    }

    public void beforeTestClass() throws Exception {
        Class<?> testClass = getTestContext().getTestClass();
        if (logger.isTraceEnabled()) {
            logger.trace("beforeTestClass(): class [" + testClass.getName() + "]");
        }
        getTestContext().updateState(null, null, null);

        for (TestExecutionListener testExecutionListener : getTestExecutionListeners()) {
            try {
                testExecutionListener.beforeTestClass(getTestContext());
            }
            catch (Throwable ex) {
                logException(ex, "beforeTestClass", testExecutionListener, testClass);
                ReflectionUtils.rethrowException(ex);
            }
        }
    }
```

**继续追踪，`ParentRunner.childrenInvoker`中的匿名内部类的`evaluate`方法**

```java
    protected Statement childrenInvoker(final RunNotifier notifier) {
        return new Statement() {
            @Override
            public void evaluate() {
                // 继续追踪
                runChildren(notifier);
            }
        };
    }

    private void runChildren(final RunNotifier notifier) {
        final RunnerScheduler currentScheduler = scheduler;
        try {
            for (final T each : getFilteredChildren()) {
                currentScheduler.schedule(new Runnable() {
                    public void run() {
                        // 继续往下追踪
                        ParentRunner.this.runChild(each, notifier);
                    }
                });
            }
        } finally {
            currentScheduler.finished();
        }
    }
```

**继续追踪，`SpringJUnit4ClassRunner.runChild`方法**

```java
    protected void runChild(FrameworkMethod frameworkMethod, RunNotifier notifier) {
        Description description = describeChild(frameworkMethod);
        if (isTestMethodIgnored(frameworkMethod)) {
            notifier.fireTestIgnored(description);
        }
        else {
            Statement statement;
            try {
                // 继续追踪
                statement = methodBlock(frameworkMethod);
            }
            catch (Throwable ex) {
                statement = new Fail(ex);
            }
            runLeaf(statement, description, notifier);
        }
    }

    protected Statement methodBlock(FrameworkMethod frameworkMethod) {
        Object testInstance;
        try {
            testInstance = new ReflectiveCallable() {
                @Override
                protected Object runReflectiveCall() throws Throwable {
                    // 继续追踪
                    return createTest();
                }
            }.run();
        }
        catch (Throwable ex) {
            return new Fail(ex);
        }

        Statement statement = methodInvoker(frameworkMethod, testInstance);
        statement = withBeforeTestExecutionCallbacks(frameworkMethod, testInstance, statement);
        statement = withAfterTestExecutionCallbacks(frameworkMethod, testInstance, statement);
        statement = possiblyExpectingExceptions(frameworkMethod, testInstance, statement);
        statement = withBefores(frameworkMethod, testInstance, statement);
        statement = withAfters(frameworkMethod, testInstance, statement);
        statement = withRulesReflectively(frameworkMethod, testInstance, statement);
        statement = withPotentialRepeat(frameworkMethod, testInstance, statement);
        statement = withPotentialTimeout(frameworkMethod, testInstance, statement);
        return statement;
    }

    public Object run() throws Throwable {
        try {
            return runReflectiveCall();
        } catch (InvocationTargetException e) {
            throw e.getTargetException();
        }
    }
```

**继续追踪，`SpringJUnit4ClassRunner.createTest`方法**

```java
    protected Object createTest() throws Exception {
        Object testInstance = super.createTest();
        // 继续追踪
        getTestContextManager().prepareTestInstance(testInstance);
        return testInstance;
    } 
```
**继续追踪，`TestContextManager.prepareTestInstance`方法**

1. 触发监听器的`TestExecutionListener.prepareTestInstance`方法

```java
    public void prepareTestInstance(Object testInstance) throws Exception {
        if (logger.isTraceEnabled()) {
            logger.trace("prepareTestInstance(): instance [" + testInstance + "]");
        }
        getTestContext().updateState(testInstance, null, null);

        for (TestExecutionListener testExecutionListener : getTestExecutionListeners()) {
            try {
                // 继续追踪
                testExecutionListener.prepareTestInstance(getTestContext());
            }
            catch (Throwable ex) {
                if (logger.isErrorEnabled()) {
                    logger.error("Caught exception while allowing TestExecutionListener [" + testExecutionListener +
                            "] to prepare test instance [" + testInstance + "]", ex);
                }
                ReflectionUtils.rethrowException(ex);
            }
        }
    }
```

**继续追踪，`ServletTestExecutionListener.prepareTestInstance`方法**

1. **这里创建`ApplicationContext`**

```java
    public void prepareTestInstance(TestContext testContext) throws Exception {
        setUpRequestContextIfNecessary(testContext);
    }

    private void setUpRequestContextIfNecessary(TestContext testContext) {
        if (!isActivated(testContext) || alreadyPopulatedRequestContextHolder(testContext)) {
            return;
        }

        // 继续追踪
        ApplicationContext context = testContext.getApplicationContext();

        if (context instanceof WebApplicationContext) {
            WebApplicationContext wac = (WebApplicationContext) context;
            ServletContext servletContext = wac.getServletContext();
            Assert.state(servletContext instanceof MockServletContext, () -> String.format(
                        "The WebApplicationContext for test context %s must be configured with a MockServletContext.",
                        testContext));

            if (logger.isDebugEnabled()) {
                logger.debug(String.format(
                        "Setting up MockHttpServletRequest, MockHttpServletResponse, ServletWebRequest, and RequestContextHolder for test context %s.",
                        testContext));
            }

            MockServletContext mockServletContext = (MockServletContext) servletContext;
            MockHttpServletRequest request = new MockHttpServletRequest(mockServletContext);
            request.setAttribute(CREATED_BY_THE_TESTCONTEXT_FRAMEWORK, Boolean.TRUE);
            MockHttpServletResponse response = new MockHttpServletResponse();
            ServletWebRequest servletWebRequest = new ServletWebRequest(request, response);

            RequestContextHolder.setRequestAttributes(servletWebRequest);
            testContext.setAttribute(POPULATED_REQUEST_CONTEXT_HOLDER_ATTRIBUTE, Boolean.TRUE);
            testContext.setAttribute(RESET_REQUEST_CONTEXT_HOLDER_ATTRIBUTE, Boolean.TRUE);

            if (wac instanceof ConfigurableApplicationContext) {
                @SuppressWarnings("resource")
                ConfigurableApplicationContext configurableApplicationContext = (ConfigurableApplicationContext) wac;
                ConfigurableListableBeanFactory bf = configurableApplicationContext.getBeanFactory();
                bf.registerResolvableDependency(MockHttpServletResponse.class, response);
                bf.registerResolvableDependency(ServletWebRequest.class, servletWebRequest);
            }
        }
    }
```

**继续追踪，`DefaultTestContext.getApplicationContext`方法**

```java
    public ApplicationContext getApplicationContext() {
        // 继续追踪
        ApplicationContext context = this.cacheAwareContextLoaderDelegate.loadContext(this.mergedContextConfiguration);
        if (context instanceof ConfigurableApplicationContext) {
            @SuppressWarnings("resource")
            ConfigurableApplicationContext cac = (ConfigurableApplicationContext) context;
            Assert.state(cac.isActive(), () ->
                    "The ApplicationContext loaded for [" + mergedContextConfiguration +
                    "] is not active. This may be due to one of the following reasons: " +
                    "1) the context was closed programmatically by user code; " +
                    "2) the context was closed during parallel test execution either " +
                    "according to @DirtiesContext semantics or due to automatic eviction " +
                    "from the ContextCache due to a maximum cache size policy.");
        }
        return context;
    }
```
**继续追踪，`DefaultCacheAwareContextLoaderDelegate.loadContext`方法**

```java
    public ApplicationContext loadContext(MergedContextConfiguration mergedContextConfiguration) {
        synchronized (this.contextCache) {
            ApplicationContext context = this.contextCache.get(mergedContextConfiguration);
            if (context == null) {
                try {
                    // 继续追踪
                    context = loadContextInternal(mergedContextConfiguration);
                    if (logger.isDebugEnabled()) {
                        logger.debug(String.format("Storing ApplicationContext in cache under key [%s]",
                                mergedContextConfiguration));
                    }
                    this.contextCache.put(mergedContextConfiguration, context);
                }
                catch (Exception ex) {
                    throw new IllegalStateException("Failed to load ApplicationContext", ex);
                }
            }
            else {
                if (logger.isDebugEnabled()) {
                    logger.debug(String.format("Retrieved ApplicationContext from cache with key [%s]",
                            mergedContextConfiguration));
                }
            }

            this.contextCache.logStatistics();

            return context;
        }
    }

    protected ApplicationContext loadContextInternal(MergedContextConfiguration mergedContextConfiguration)
            throws Exception {

        ContextLoader contextLoader = mergedContextConfiguration.getContextLoader();
        Assert.notNull(contextLoader, "Cannot load an ApplicationContext with a NULL 'contextLoader'. " +
                "Consider annotating your test class with @ContextConfiguration or @ContextHierarchy.");

        ApplicationContext applicationContext;

        if (contextLoader instanceof SmartContextLoader) {
            SmartContextLoader smartContextLoader = (SmartContextLoader) contextLoader;
            // 继续追踪
            applicationContext = smartContextLoader.loadContext(mergedContextConfiguration);
        }
        else {
            String[] locations = mergedContextConfiguration.getLocations();
            Assert.notNull(locations, "Cannot load an ApplicationContext with a NULL 'locations' array. " +
                    "Consider annotating your test class with @ContextConfiguration or @ContextHierarchy.");
            applicationContext = contextLoader.loadContext(locations);
        }

        return applicationContext;
    }
```
**继续追踪，`SpringBootContextLoader.loadContext`方法**

1. 这里启动了`SpringBoot`

```java
    public ApplicationContext loadContext(MergedContextConfiguration config)
            throws Exception {
        Class<?>[] configClasses = config.getClasses();
        String[] configLocations = config.getLocations();
        Assert.state(
                !ObjectUtils.isEmpty(configClasses)
                        || !ObjectUtils.isEmpty(configLocations),
                () -> "No configuration classes "
                        + "or locations found in @SpringApplicationConfiguration. "
                        + "For default configuration detection to work you need "
                        + "Spring 4.0.3 or better (found " + SpringVersion.getVersion()
                        + ").");
        // 创建SpringApplication的实例
        SpringApplication application = getSpringApplication();
        application.setMainApplicationClass(config.getTestClass());
        application.addPrimarySources(Arrays.asList(configClasses));
        application.getSources().addAll(Arrays.asList(configLocations));
        ConfigurableEnvironment environment = getEnvironment();
        if (!ObjectUtils.isEmpty(config.getActiveProfiles())) {
            setActiveProfiles(environment, config.getActiveProfiles());
        }

        // 设置资源加载器
        ResourceLoader resourceLoader = (application.getResourceLoader() != null)
                ? application.getResourceLoader()
                : new DefaultResourceLoader(getClass().getClassLoader());
        TestPropertySourceUtils.addPropertiesFilesToEnvironment(environment,
                resourceLoader, config.getPropertySourceLocations());
        TestPropertySourceUtils.addInlinedPropertiesToEnvironment(environment,
                getInlinedProperties(config));

        // 设置Environment对象
        application.setEnvironment(environment);

        // 创建初始化器，每个初始化器都包含了config
        List<ApplicationContextInitializer<?>> initializers = getInitializers(config,
                application);

        // 设置WebApplicationType
        if (config instanceof WebMergedContextConfiguration) {
            application.setWebApplicationType(WebApplicationType.SERVLET);
            if (!isEmbeddedWebEnvironment(config)) {
                // 这里会将config中的resourceBasePath封装到initializers中去
                new WebConfigurer().configure(config, application, initializers);
            }
        }
        else if (config instanceof ReactiveWebMergedContextConfiguration) {
            application.setWebApplicationType(WebApplicationType.REACTIVE);
            if (!isEmbeddedWebEnvironment(config)) {
                new ReactiveWebConfigurer().configure(application);
            }
        }
        else {
            application.setWebApplicationType(WebApplicationType.NONE);
        }

        // 设置初始化器
        application.setInitializers(initializers);
        return application.run();
    }

    protected List<ApplicationContextInitializer<?>> getInitializers(
            MergedContextConfiguration config, SpringApplication application) {
        List<ApplicationContextInitializer<?>> initializers = new ArrayList<>();
        for (ContextCustomizer contextCustomizer : config.getContextCustomizers()) {
            initializers.add(new ContextCustomizerAdapter(contextCustomizer, config));
        }
        initializers.addAll(application.getInitializers());
        for (Class<? extends ApplicationContextInitializer<?>> initializerClass : config
                .getContextInitializerClasses()) {
            initializers.add(BeanUtils.instantiateClass(initializerClass));
        }
        if (config.getParent() != null) {
            initializers.add(new ParentContextApplicationContextInitializer(
                    config.getParentApplicationContext()));
        }
        return initializers;
    }
```

## 2.3 关键对象的层级结构

```
SpringJUnit4ClassRunner
        |
        └── testContextManager (TestContextManager)
                |
                └── testContext (TestContext)
                        |
                        ├── attributes (Map<String, Object>)
                        ├── cacheAwareContextLoaderDelegate (CacheAwareContextLoaderDelegate)
                        ├── mergedContextConfiguration (MergedContextConfiguration)
                        ├── testClass (Class<?>)
                        ├── testInstance (Object)
                        ├── testMethod (Method)
                        └── testException (Throwable)
```
