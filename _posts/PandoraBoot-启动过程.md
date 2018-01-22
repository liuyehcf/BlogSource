---
title: PandoraBoot-启动过程
date: 2018-01-07 22:20:37
tags: 
- 原创
categories: 
- Java
- Framework
- Pandora
password: 19930101
---

__目录__

<!-- toc -->
<!--more-->

# 1 Application#main

[Demo工程下载地址](http://hsf.alibaba.net/hsfops/bootstrap/mwBootstrap.htm?spm=a1zco.hsf.0.0.ardhiP&envType=daily)。Pandora版本号是2.1.7.10

Application.main是启动整个应用的入口。其中，`PandoraBootstrap.run(args);`必须作为第一条语句，否则可能会造成一些问题，后面会详细介绍

```Java
@SpringBootApplication(scanBasePackages = {"com.alibaba.middleware"})
public class Application {

    public static void main(String[] args) {
        // 必须作为第一条语句
        PandoraBootstrap.run(args);

        // 应用
        SpringApplication.run(Application.class, args);

        // hold当前线程
        PandoraBootstrap.markStartupAndWait();
    }
}
```

# 2 PandoraBootstrap#run

PandoraBootstrap#run的主要步骤

1. 设置系统参数：PandoraBoot的版本号（非重点）
1. 控制PandoraBoot仅初始化一次（重点）
1. 从启动类的类加载器获取当前类资源（包括-classpath参数指定的，以及JAVA_HOME下的一些核心以及扩展jar包）
1. 创建一个只包含`autoconf.jar`和`pandora-boot-autoconf.jar`的类加载器（避免被污染），然后加载Autoconfigure，并利用反射执行config方法（非重点）
1. ReLaunchMainLauncher#launch方法（重点）

```Java
    public static void run(String[] args) {
        if (argsConatinPandoraLocation(args)) {
            AnsiLog.error("[ERROR] Please don't set -Dpandora.location in Program arguments, set in VM arguments. "
                    + "Google 'Program arguments VM arguments'.");
        }

        // 设置系统参数：PandoraBoot的版本号
        VersionUtils.setPandoraBootStarterVersionSystemProperty();

        // Pandora Boot应用中，main函数会被启动两次，这里控制只启动一次
        if (SarLoaderUtils.unneedLoadSar()) {
            LogConfigUtil.initLoggingSystem();
            return;
        }

        // 以下代码仅在第一次启动时会运行，此时PandoraBootstrap的类加载器是AppClassLoader

        // 这里通过AppClassLoader获取所有jar包的资源，包括bootstrap加载的核心jar包，ext加载的扩展jar包，以及classpath指定的所有jar包
        URL[] urls = ClassLoaderUtils.getUrls(PandoraBootstrap.class.getClassLoader());
        if (urls == null) {
            throw new IllegalStateException("Can not find urls from the ClassLoader of PandoraBootstrap. ClassLoader: "
                    + PandoraBootstrap.class.getClassLoader());
        }

        // Construct a classloader which only contains autoconf.jar and pandora-boot-autoconf.jar, then use it to load Autoconfigure and call its method 'config'
        urls = AutoConfigWrapper.autoConfig(urls);

        // 然后进入launch方法
        ReLaunchMainLauncher.launch(args, deduceMainApplicationClass().getName(), urls);
    }
```

## 2.1 ReLaunchMainLauncher#launch

ReLaunchMainLauncher#launch的主要步骤

1. 创建一个URLClassLoader，该URLClassLoader可以加载当前应用可以加载的所有类。同时，该URLClassLoader还包含了各个中间件导出类的缓存（类隔离的关键）
1. 退出当前线程。也就是main函数除了第一句，后面的都不执行了，是不是很奇怪？请继续往下看

```Java
    public static void launch(String[] args, String mainClass, URL[] urls) {

        // reLaunch 里以一个新线程，新classloader启动main函数，并等待新的main函数线程退出
        reLaunch(args, mainClass, createClassLoader(urls));

        // 执行到这里，新启动的main线程已经退出了，可以直接退出进程
        // 也就是说，main函数仅仅运行到这里就结束了，main函数的其他逻辑是通过反射调用main函数来完成的
        System.exit(0);
    }
```

### 2.1.1 ReLaunchURLClassLoader

ReLaunchMainLauncher是Pandora中最核心的类加载器，它连接了原本位于各自类加载器命名空间下的中间件导出类以及应用相关的类

我们首先来看下ReLaunchURLClassLoader的几个重要方法。首先是构造方法，其中`rootClassLoader`字段保存了传入的双亲类加载器

```Java
    public ReLaunchURLClassLoader(URL[] urls, ClassLoader parent) {
		super(urls, parent);
		this.rootClassLoader = findRootClassLoader(parent);
	}
```

重关注一下loadClass方法，这是更改类加载机制的关键之处

先来看看类加载器的根基类`ClassLoader`中的loadClass是如何实现的，我们常说的双亲委派模型是在这个方法中得以体现的

1. 首先调用findLoadedClass从JVM中以`类加载器引用`和`类限定名`作为key查询Class的缓存，如果命中则直接返回
1. 其次，若parent（双亲类加载器的引用）不为空，那么用双亲类加载器加载该类
1. 若parent为空，说明当前类加载器的父加载器就是bootstrapClassLoader（这不是一个Java对象，存在于JVM中，因此parent字段是null）
1. 若上层类加载器都未正确加载类，那么再调用当前类加载器的loadClass进行类加载
1. 根据入参`resolve`决定是否解析该类

```Java
    protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
    {
        synchronized (getClassLoadingLock(name)) {
            // First, check if the class has already been loaded
            Class<?> c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                try {
                    if (parent != null) {
                        // 调用双亲类加载器加载
                        c = parent.loadClass(name, false);
                    } else {
                        // 调用bootstrap类加载器加载
                        c = findBootstrapClassOrNull(name);
                    }
                } catch (ClassNotFoundException e) {
                    // ClassNotFoundException thrown if class not found
                    // from the non-null parent class loader
                }

                if (c == null) {
                    // If still not found, then invoke findClass in order
                    // to find the class.
                    long t1 = System.nanoTime();
                    c = findClass(name);

                    // this is the defining class loader; record the stats
                    sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                    sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                    sun.misc.PerfCounter.getFindClasses().increment();
                }
            }
            if (resolve) {
                resolveClass(c);
            }
            return c;
        }
    }
```

然后，我们再来看一下ReLaunchURLClassLoader是如何对loadClass进行改造的

1. 首先在`classCache`中__仅仅以类全限定名作为key__进行查找（classCache的类型是`Map<String, Class<?>>`），这是连接__位于不同命名空间__（一个类加载器的引用对应于一个命名空间）的Class实例的关键
1. 调用findLoadedClass从JVM中以`类加载器引用`和`类限定名`作为key查询Class的缓存，如果命中则直接返回
1. 调用doLoadClass进行加载，接着往下看doLoadClass的逻辑

```Java
@Override
	protected Class<?> loadClass(String name, boolean resolve)
			throws ClassNotFoundException {
		synchronized (ReLaunchURLClassLoader.LOCK_PROVIDER.getLock(this, name)) {
            // 看到没有，将各个中间件导出的类放到了一个缓存中，当应用加载类的时候，会顺着委派路径到达该类加载器ReLaunchURLClassLoader，于是就可以从缓存中取出相应的类了
			if (classCache != null && classCache.containsKey(name)) {
				return classCache.get(name);
			}
			Class<?> loadedClass = findLoadedClass(name);
			if (loadedClass == null) {
				Handler.setUseFastConnectionExceptions(true);
				try {
                    // 执行自定义的类加载过程
					loadedClass = doLoadClass(name);
				}
				finally {
					Handler.setUseFastConnectionExceptions(false);
				}
			}
			if (resolve) {
				resolveClass(loadedClass);
			}
			super.recordClass(loadedClass);
			return loadedClass;
		}
	}
```

doLoadClass用于加载应用相关的类以及JDK核心类

1. 利用rootClassLoader加载，保证了安全性。结合Application#main来看，这个rootClassLoader就是ExeClassLoader
1. 利用当前类加载器进行加载
1. 利用系统/应用类加载器进行加载

```Java
private Class<?> doLoadClass(String name) throws ClassNotFoundException {

		// 1) Try the root class loader
        // rootClassLoader一般就是ExtClassLoader
		try {
			if (this.rootClassLoader != null) {
				return this.rootClassLoader.loadClass(name);
			}
		}
		catch (Exception ex) {
			// Ignore and continue
		}

		// 2) Try to find locally
        // 利用当前类加载器加载，由于该加载器包含了所有classpath的URL，因此AppClassLoader能加载的类，这里都能加载到
		try {
			findPackage(name);
			Class<?> cls = findClass(name);
			return cls;
		}
		catch (Exception ex) {
			// Ignore and continue
		}

		// 3) Try to find SystemClassLoader. agent jar should load by SystemClassLoader. middleware-container/pandora-boot#638
		try {
			return systemClassLoader.loadClass(name);
		}
		catch (Exception ex) {
			// Ignore and continue
		}

		// 4) Use standard loading
		return super.loadClass(name, false);
	}
```

### 2.1.2 ReLaunchMainLauncher#createClassLoader

ReLaunchMainLauncher#createClassLoader的主要步骤

1. 创建一个ReLaunchURLClassLoader（URLClassLoader的子类）
1. 

```Java
static ClassLoader createClassLoader(URL[] urls){
        long t1 = System.nanoTime();
        Health.registMBean();
        SystemPrintUtil.switchSystemPrint();

        // parent设置为ext classloader，避免某些情况下应用向上查找parent，利用parent来加载资源，从而利用到SystemClassLoader 来加载类
        // 排除掉-javaagent指定的jar包，因此AppClassLoader能加载的类，ReLaunchURLClassLoader都能加载
        // 同时，ReLaunchURLClassLoader必须能够绕开AppClassLoader
        ReLaunchURLClassLoader reLaunchClassLoader = new ReLaunchURLClassLoader(cleanJavaAgentUrls(urls),
                ClassLoader.getSystemClassLoader().getParent());

        try {
            Archive sar = SarLoaderUtils.findExternalSar();
            if (sar == null) {
                sar = SarLoaderUtils.findFromClassPath(urls);
                if (sar == null) {
                    if ("true".equalsIgnoreCase(System.getProperty(Constants.FAILFAST_PROPERTY_KEY))) {
                        throw new RuntimeException("can not load taobao-hsf.sar, please check your config!");
                    }
                    AnsiLog.error("Can not load taobao-hsf.sar! If you do not use taobao-hsf.sar, ignore this. "
                        + "Otherwise please check '-Dpandora.location=' or maven dependencies if there contains taobao-hsf.sar!");
                }
            }

            if (sar != null) {
                // 这里创建了各个模块的导出类的缓存，核心中的核心
                Map<String, Class<?>> classCache = SarLoaderUtils.getClassCache(sar, reLaunchClassLoader);

                reLaunchClassLoader.setClassCache(classCache);
            }

            // 标记pandora已经启动
            SarLoaderUtils.markSarLoaderUtils(reLaunchClassLoader, "sarLoaded", true);
            SarLoaderUtils.markSarLoaderUtils(reLaunchClassLoader, "t1", t1);
            // collect class info
            reLaunchClassLoader.collectStaticClassInfo();
        } catch (Exception e) {
            throw new RuntimeException("load pandora error!", e);
        }
        return reLaunchClassLoader;
    }
```

#### 2.1.2.1 SarLoaderUtils#getClassCache

SarLoaderUtils#getClassCache。注意噢，这里传入的bizClassLoader，就是上面讨论过的ReLaunchURLClassLoader

```Java
public static Map<String, Class<?>> getClassCache(Archive sar, ClassLoader bizClassLoader) throws Exception {
        // 打印Pandora
        printBanner(bizClassLoader);
        configHostType();
        configTddlVersionCheck();
        configureHeadlessProperty();

        Map<String, Archive> pluginsFromSar = loadPlugins(sar);

        // 取得所有Pandora内部持有的Plgin（就是集团中间件）的RUL
        List<URL> pluginJarUrls = Collections.emptyList();
        if (!ignorePackagedPlugins()) {
            // 从bizClassLoader里查找所有的plugin jar，并获取它们的url
            pluginJarUrls = new ArrayList<URL>();
            Enumeration<URL> pluginPropertiesResources = bizClassLoader.getResources(PLUGIN_GUIDE_PROPERTIES);
            while (pluginPropertiesResources.hasMoreElements()) {
                URL guidePropertiesUrl = pluginPropertiesResources.nextElement();
                String pluginArtifactId = readPluginArtifactId(guidePropertiesUrl);
                // 在sar包里不存在的plugin加到pluginJarUrls里
                if (pluginArtifactId != null && !pluginsFromSar.containsKey(pluginArtifactId)) {
                    pluginJarUrls.add(ArchiveUtils.createArchiveFromUrl(guidePropertiesUrl).getUrl());
                }
            }
        }

        URL url = sar.getUrl();

        // 获取Pandora容器自身依赖的核心jar
        // 通过debug，你可以定位到Pandora依赖的类库的位置，方便后续debug（这些class文件不在classpath当中，因此IDE是找不到的）
        List<Archive> jars = sar.getNestedArchives(new Archive.EntryFilter() {

            @Override
            public boolean matches(Archive.Entry entry) {
                String entryName = entry.getName();
                // 排除掉隐藏目录
                if (entryName.length() > LIB.length() && entryName.charAt(LIB.length()) == '.') {
                    System.out.println("entryName is a hidden directory in sar, ignore: " + entryName);
                    return false;
                }
                return !entry.isDirectory() && entryName.startsWith(LIB);
            }
        });

        // 将获取到的Pandora容器自身依赖的核心jar，转换成URL
        URL[] urls = new URL[jars.size()];
        for (int i = 0; i < jars.size(); i++) {
            urls[i] = jars.get(i).getUrl();
        }

        @SuppressWarnings("resource")

        // 这个类加载器的父加载器是ExtClassLoader，并且传入了Pandora容器自身依赖的jar包URL，因此该加载器有能力加载Pandora容器的相关类
        ClassLoader classLoader = new URLClassLoader(urls, ClassLoader.getSystemClassLoader().getParent());
        String defaultInitOverride = System.getProperty(LOG4J_DEFAULTINITOVERRIDE);

        if (defaultInitOverride == null) {
            System.out.println("Set log4j.defaultInitOverride to true.");
            System.setProperty(LOG4J_DEFAULTINITOVERRIDE, "true");
        }

        // 这个线程上下文加载器一般就是AppClassLoader
        ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
        try {
            URL[] pluginUrls = pluginJarUrls.toArray(new URL[pluginJarUrls.size()]);

            // 用指定加载器加载com.taobao.pandora.PandoraContainer
            Class<?> pandora = classLoader.loadClass("com.taobao.pandora.PandoraContainer");

            // 将线程上下文类加载器设置为上面那个classLoader
            Thread.currentThread().setContextClassLoader(pandora.getClassLoader());
            Constructor<?> constructor = pandora.getConstructor(URL.class, URL[].class, ClassLoader.class);
            // 注意这里传入的是bizClassLoader，就是之前分析到的那个ReLaunchURLClassLoader
            Object instance = constructor.newInstance(url, pluginUrls, bizClassLoader);

            // 通过反射调用，初始化Pandora容器
            invokeStart(instance);

            checkFileDescriptorCount();

            return invokeGetExportedClasses(instance);
        } finally {
            Thread.currentThread().setContextClassLoader(contextClassLoader);
        }

    }
```

# 3 PandoraContainer的启动过程

接下来查看PandoraContainer的启动过程，下面的debug依赖于`~/.m2/repository/com/taobao/pandora/taobao-hsf.sar-container/2017-12-release/taobao-hsf.sar-container-2017-12-release.jar`中的lib目录下的jar包

PandoraContainer.start

```Java
    public void start() throws Exception {
        AssertUtils.assertNotNull(this.serviceContainer, "service container is null");
        if(this.started.compareAndSet(false, true)) {
            this.serviceContainer.start();
            // 创建pipeLine
            Pipeline pipeline = (Pipeline)this.serviceContainer.getService(Pipeline.class);
            // 核心方法
            pipeline.execute(this.pipelineContext);
            System.out.println("\nPandora container started in " + (System.currentTimeMillis() - this.start) + " ms.\n");
        }

    }
```

PipeLine.execute

```Java
    public void execute(PipelineContext context) {
        // 由于PipeLine是由CurrentClassLoader加载的，而CurrentClassLoader就是PandoraContainer的类加载器，也就是SarLoaderUtils#getClassCache方法中创建的那个URLClassLoader
        ClassLoader pandoraClassLoader = Pipeline.class.getClassLoader();
        
        // 更改线程上下文类加载器
        ClassLoader savedClassLoader = ContextLoaderUtils.pushContextClassLoader(pandoraClassLoader);

        try {
            log.info("Pipeline", "process begin.");
            if(this.headNode != null) {
                this.headNode.stepIn(context);
            }

            log.info("Pipeline", "process end.");
        } catch (PandoraException var8) {
            log.error("Pipeline", ErrorCode.EXECUTE_PIPELINE_STAGE_ERROR.getCode(), "process got exception.", var8);
            throw new RuntimeException(var8);
        } finally {
            ContextLoaderUtils.popContextClassLoader(savedClassLoader);
        }

    }
```

# 4 PipeLine处理流程

接下来将进入一系列的处理流程

StageNode.stepIn。每个StageNode都绑定了一个target，执行完target的stepIn，然后继续调用下一个节点的stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        long now = System.currentTimeMillis();
        // 执行目标动作
        target.stepIn(context);
        logger.info("Stage", "{} takes {} ms.", target.getClass().getSimpleName(), (System.currentTimeMillis() - now));

        if (nextNode != null) {
            // 跳转到下一个节点继续处理流程
            nextNode.stepIn(context);
        } else {
            stepOut(context);
        }
    }
```

## 4.1 Log4jDefaultInitOverride.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        String override = System.getProperty("log4j.defaultInitOverride");
        if(override == null) {
            if(log.isDebugEnabled()) {
                log.debug("Stage-Log4jDefaultInitOverride", "set log4j.defaultInitOverride to true.");
            }

            System.setProperty("log4j.defaultInitOverride", "true");
        }

    }
```

## 4.2 MergeFolderPlugin.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        // 从containerArchive里加载所有的plugins下面的插件，支持开放目录的插件，或者以 jar.plugin 结尾的jar插件
        // 为每一个Plugin创建一个plugin archive
        // 另外，合并外部指定的目录，最终生成一个<name, PluginArchive>的map，存到PipelineContext里

        Archive containerArchive = (Archive) context.get(PipelineContextKey.PANDORA_CONTAINER_ARCHIVE);
        Map<String, Archive> pluginArchiveMap = loadPlugins(containerArchive);
        
        // 合并 PipelineContextKey.PLUGIN_URLS 的插件
        URL[] pluginUrls = (URL[]) context.get(PipelineContextKey.PLUGIN_URLS);
        if (pluginUrls != null) {
            for (URL url : pluginUrls) {
                try {
                    Archive pluginArchive = ArchiveUtils.createArchiveFromUrl(url);
                    Properties guideProperties = IOUtils.readProperties(pluginArchive.getResource(PLUGIN_GUIDE_PROPERTIES));
                    AssertUtils.assertNotNull(guideProperties,
                                              "can not load guide properties from archive:" + pluginArchive.getUrl());
                    // 从plugin jar里的plugin.guide.properties 里读取到 plugin name
                    String pluginName = guideProperties.getProperty("artifactId");
                    AssertUtils.assertNotNull(pluginName, "plugin name can not be null");
                    pluginArchiveMap.put(pluginName, pluginArchive);
                } catch (IOException e) {
                    throw new PandoraException("load plugin archive error!, url: " + url, e);
                }
            }
        }

        // 获取-D参数指定的外部插件文件夹路径
        String ext = System.getProperty(EXTERNAL_PLUGIN_PATH);
        if (log.isDebugEnabled()) {
            log.debug("Stage-MergeFolderPlugin", "-D" + EXTERNAL_PLUGIN_PATH + ": " + ext);
        }
        File[] externalPlugins = getExternalPlugins(ext);
        if (externalPlugins != null) {
            // 外部路径的插件覆盖内部的
            for (File extPlugin : externalPlugins) {
                // 不部署隐藏目录
                if (extPlugin.isHidden()) {
                    log.info("Stage-MergeFolderPlugin", "[{}] is a hidden directory in sar, ignore.",
                             extPlugin.getName());
                } else {
                    pluginArchiveMap.put(extPlugin.getName(), new ExplodedArchive(extPlugin));
                }
            }
        }
        // 放入PipelineContext
        context.put(PipelineContextKey.PLUGIN_ARCHIVES_MAP, pluginArchiveMap);
    }
```

## 4.3 DeployPluginModule.stepIn

这一步会为每个中间件生成一个独享的ModuleClassLoader，来形成加载时隔离的环境，避免中间件的依赖相互污染

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        Map<String, Archive> pluginArchives = (Map<String, Archive>) context.get(PipelineContextKey.PLUGIN_ARCHIVES_MAP);
        final CountDownLatch latch = new CountDownLatch(pluginArchives.size());
        for(final Entry<String, Archive> entry : pluginArchives.entrySet()){
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        Module module = deployService.deployModule(entry.getValue(), entry.getKey());
                        if (log.isDebugEnabled()) {
                            log.debug("Stage-DeployPluginModule", "deploy module:" + module.getName());
                        }
                    } finally {
                        latch.countDown();
                    }
                }
            }, "DeployPluginModule-" + entry.getKey()).start();

        }
        try {
            latch.await();
        } catch (InterruptedException e) {
            throw new PandoraException(e);
        }
    }

```

### 4.3.1 DeployServiceImpl.deployModule

```Java
    @Override
    public Module deployModule(Archive archive, String name) throws PandoraException {
        if (log.isDebugEnabled()) {
            try {
                log.debug("DeployService", "deploy module @" + archive.getUrl());
            } catch (MalformedURLException e) {
                throw new PandoraException(e);
            }
        }

        // 已经安装，返回module的name
        if (modules.containsKey(name)) {
            log.warn("DeployService", "module {} is already deployed", name);
            return modules.get(name);
        }

        // 有并发风险重复创建模块，但是实际并不会发生
        PluginModule pluginModule = moduleFactory.createModule(archive, name);
        pluginModule.setModuleState(ModuleState.DEPLOYING);
        modules.putIfAbsent(name, pluginModule);

        log.info("DeployService", "deployed module {}, location: {}", name, archive);
        if (log.isDebugEnabled()) {
            log.debug("DeployService", "module info: {}", pluginModule);
        }

        return pluginModule;
    }
```

### 4.3.2 PluginModuleFactory.createModule

```Java
    public PluginModule createModule(Archive archive, String name) throws PandoraException {
        // TODO name 可能是jar名，或者是文件夹的名字
        PluginModule module = new PluginModule();
        module.setName(name);
        module.setArchive(archive);
        module.setDeployTime(new Date());
        parsePriority(module);
        parseVersion(module);
        parseImports(module);
        parseExports(module);
        parseInitializer(module);
        parseService(module);
        parseLifecycleListeners(module);
        setupClassLoader(module);
        return module;
    }
```

### 4.3.3 PluginModuleFactory.setupClassLoader

这一步创建了ModuleClassLoader

```Java
    /**
     * 构建ModuleClassLoader
     */
    void setupClassLoader(PluginModule module) throws PandoraException {
        String name = module.getName();
        CreateLoaderParam createLoaderParam = new CreateLoaderParam();
        createLoaderParam.setModuleName(name);
        createLoaderParam.setUseBizClassLoader(module.getImportInfo().isUseBizClassLoader());
        createLoaderParam.setUseSystemClassLoader(module.getImportInfo().isUseSystemClassLoader());
        createLoaderParam.setImportPackageList(module.getImportInfo().getImportPackageList());
        
        URL[] libFiles;
        try {
            libFiles = module.getLibFileUrls().toArray(new URL[0]);
        } catch (IOException e) {
            throw new PandoraException("get module lib files error!, module:" + module.getName(), e);
        }
        if (libFiles != null) {
            createLoaderParam.setRepository(libFiles);
        }
        ClassLoader classLoader = classLoaderService.createModuleClassLoader(createLoaderParam);
        module.setClassLoader(classLoader);
    }
```

## 4.4 InitializerCheck.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        List<Module> moduleList = deployService.listModules();
        if (moduleList == null || moduleList.isEmpty()) {
            return;
        }

        for (Module module : moduleList) {
            if (initializerChecker.checkModule(module.getName())) {
                if (log.isDebugEnabled()) {
                    log.debug("Stage-InitializerCheck", "module {} permit to start.", module.getName());
                }
            } else {
                PluginModule pluginModule = (PluginModule) module;
                pluginModule.setModuleState(ModuleState.UNDEPLOYED);
                if (log.isDebugEnabled()) {
                    log.debug("Stage-InitializerCheck", "module {} NOT permit to start.", module.getName());
                }
            }
        }
    }
```

## 4.5 ExportClass2Cache.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        List<Module> moduleList = deployService.listModules();
        if (moduleList != null) {
            for (Module module : moduleList) {
                int count = classExporter.exportClasses(module.getName());

                if (log.isDebugEnabled()) {
                    log.debug("Stage-ExportClass2Cache", "module {} export {} classes.", module.getName(), count);
                }
            }
        }
    }
```

### 4.5.1 ClassExporter.exportClasses

```Java
/**
     * 导出Module的类到缓存中
     *
     * @param moduleName 模块名
     * @return 导出类的总数
     */
    public int exportClasses(String moduleName) throws PandoraException {
        PluginModule module = (PluginModule) deployService.findModule(moduleName);
        if (module == null || module.getModuleState() != ModuleState.DEPLOYING) {
            return 0;
        }

        if (exportIndexEnabled) {
            int scanFromExportIndex = scanFromExportIndex(module);
            if (scanFromExportIndex != -1) {
                return scanFromExportIndex;
            }
        }

        int count = 0;

        for (Class<?> clazz : scanJars(module)) {
            Class<?> existing = sharedClassService.putIfAbsent(moduleName, clazz);
            if (existing == null) {
                count++;
            }
        }

        for (Class<?> clazz : scanPackages(module)) {
            Class<?> existing = sharedClassService.putIfAbsent(moduleName, clazz);
            if (existing == null) {
                count++;
            }
        }

        for (Class<?> clazz : scanClasses(module)) {
            Class<?> existing = sharedClassService.putIfAbsent(moduleName, clazz);
            if (existing == null) {
                count++;
            }
        }

        return count;
    }
```

### 4.5.2 ClassExporter.scanFromExportIndex

每个中间件需要导出的类都写在一个文件里面，解析这个文件然后用ModuleClassLoader去加载，然后放入ReLaunchURLClassLoader的缓存当中去

```Java
    /**
     * 尝试从 conf/export.index 加载导出类，如果没有找到，则返回 -1。index文件由pandora maven plugin生成
     *
     * @param module
     * @return
     */
    private int scanFromExportIndex(PluginModule module) throws PandoraException {
        String moduleName = module.getName();
        URL index = module.getArchive().getResource(EXPORT_INDEX);
        if (index != null) {
            List<String> classes = new ArrayList<String>();
            BufferedReader bufferedReader = null;
            try {
                bufferedReader = new BufferedReader(new InputStreamReader(index.openStream()));
                String clazz = null;
                while ((clazz = bufferedReader.readLine()) != null) {
                    if (StringUtils.isNotBlank(clazz)) {
                        classes.add(clazz);
                    }
                }
                log.info("ClassExporter", "module: {} load export classes index from {}, size: {}", moduleName, EXPORT_INDEX, classes.size());
            } catch (IOException e) {
                throw new PandoraException(e);
            } finally {
                if (bufferedReader != null) {
                    IOUtils.ensureClose(bufferedReader);
                }
            }

            ClassLoader classLoader = module.getClassLoader();
            ExportInfo exportInfo = module.getExportInfo();
            int loadedClassCount = 0;
            for (String clzName : classes) {
                try {
                    Class<?> clz = classLoader.loadClass(clzName);
                    Class<?> existing = sharedClassService.putIfAbsent(moduleName, clz);
                    if (existing == null) {
                        loadedClassCount++;
                    }
                    if (log.isDebugEnabled()) {
                        log.debug("ClassExporter", "{} export class: {}", moduleName, clz.getName());
                    }
                } catch (Throwable t) {
                    throwIfNotOptional(exportInfo, clzName, moduleName, t);
                }
            }
            return loadedClassCount;
        }
        return -1;
    }
```

## 4.6 RegisterPandoraService.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        List<Module> moduleList = deployService.listModules();
        if (moduleList == null || moduleList.isEmpty()) {
            return;
        }

        final CountDownLatch latch = new CountDownLatch(moduleList.size());
        for (final Module module : moduleList) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        pandoraServiceManager.registerPandoraService(module.getName());
                        if (log.isDebugEnabled()) {
                            log.debug("Stage-RegisterPandoraService", "register {}'s PandoraService.", module.getName());
                        }
                    } finally {
                        latch.countDown();
                    }
                }
            }, "RegisterPandoraService-" + module.getName()).start();
        }

        try {
            latch.await();
        } catch (InterruptedException e) {
            // ignore
        }
    }
```

## 4.7 RegisterLifecycleListener.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        List<Module> moduleList = deployService.listModules();
        LifecycleServiceImpl impl = (LifecycleServiceImpl) lifecycleService;
        if (moduleList != null) {
            for (Module module : moduleList) {
                impl.registerModuleListener(module.getName());
                if (log.isDebugEnabled()) {
                    log.debug("[Stage-RegisterLifecycleListener] register " + module.getName()
                              + "'s LifecycleListener.");
                }
            }
        }
    }
```

## 4.8 ChangeStateDeployed.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        List<Module> moduleList = deployService.listModules();
        if (moduleList != null) {
            for (Module module : moduleList) {
                PluginModule pluginModule = (PluginModule) module;
                // DEPLOYING --> DEPLOYED
                if (pluginModule.getModuleState() == ModuleState.DEPLOYING) {
                    pluginModule.setModuleState(ModuleState.DEPLOYED);
                    if (log.isDebugEnabled()) {
                        log.debug("Stage-ChangeStateDeployed", "change module {} [DEPLOYED]", module.getName());
                    }
                }
            }
        }

    }
```

## 4.9 StartPandoraService.stepIn

```Java
    public void stepIn(PipelineContext context) throws PandoraException {
        pandoraServiceManager.startPandoraService();

        if (log.isDebugEnabled()) {
            log.debug("Stage-StartPandoraService", "started PandoraService.");
        }

    }

```

# 5 ReLaunchMainLauncher.reLaunch

回到ReLaunchMainLauncher.launch方法中，继续看reLaunch方法。至此Pandora环境构建完毕，现在要重新运行main函数

```Java
    public static void reLaunch(String[] args, String mainClass, ClassLoader classLoader) {
        IsolatedThreadGroup threadGroup = new IsolatedThreadGroup(mainClass);
        Thread launchThread = new Thread(threadGroup, new LaunchRunner(mainClass, args), "main");

        // 将线程上下文类加载器设置为传入的classLoader（就是那个ReLaunchURLClassLoader）
        launchThread.setContextClassLoader(classLoader);
        launchThread.start();
        LaunchRunner.join(threadGroup);
        threadGroup.rethrowUncaughtException();
    }
```

再看下LaunchRunner的逻辑

```Java
    public void run() {
        Thread thread = Thread.currentThread();
        // 取出线程上下文类加载器
        ClassLoader classLoader = thread.getContextClassLoader();
        Object componentManager = ComponentsManagerLoadUtils.getInstance(classLoader);
        try {
            ComponentsManagerLoadUtils.initComponentsManager(componentManager);
            ComponentsManagerLoadUtils.startComponentsManager(componentManager);

            // 用线程上下文类加载器加载起始类（就是之前包含main方法的那个类）
            // 这样一来，反射调用的main方法的CurrentClassLoader就是这个classLoader，也就是ReLaunchURLClassLoader了
            Class<?> startClass = classLoader.loadClass(this.startClassName);
            Method mainMethod = startClass.getMethod("main", String[].class);
            if (!mainMethod.isAccessible()) {
                mainMethod.setAccessible(true);
            }
            mainMethod.invoke(null, new Object[]{this.args});
        } catch (NoSuchMethodException ex) {
            Exception wrappedEx = new Exception(
                    "The specified mainClass doesn't contain a " + "main method with appropriate signature.", ex);
            thread.getThreadGroup().uncaughtException(thread, wrappedEx);
        } catch (Exception ex) {
            thread.getThreadGroup().uncaughtException(thread, ex);
        } finally {
            ComponentsManagerLoadUtils.stopComponentsManager(componentManager);
        }
    }
```

# 6 小插曲

情景，我想要通过反射拿到ReLaunchURLClassLoader的classCache

于是我写下如下代码：

```java
package com.alibaba.middleware;

import com.taobao.pandora.boot.PandoraBootstrap;
import com.taobao.pandora.boot.loader.ReLaunchURLClassLoader;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.lang.reflect.Field;
import java.util.Map;

/**
 * Pandora Boot应用的入口类
 *
 * @author chengxu
 */
@SpringBootApplication(scanBasePackages = {"com.alibaba.middleware"})
public class Application {

    public static void main(String[] args) throws Exception {
        PandoraBootstrap.run(args);

        // start
        ReLaunchURLClassLoader reLaunchURLClassLoader = (ReLaunchURLClassLoader)Application.class.getClassLoader();
        Field classCacheField = reLaunchURLClassLoader.getClass().getSuperclass().getDeclaredField("classCache");
        classCacheField.setAccessible(true);
        Map<String, Class<?>> classCache = (Map<String, Class<?>>) classCacheField.get(reLaunchURLClassLoader);
        System.err.println("success!");
        // end

        SpringApplication.run(Application.class, args);
        PandoraBootstrap.markStartupAndWait();
    }
}
```

结果抛出了如下异常

```java
...
Caused by: java.lang.ClassCastException: com.taobao.pandora.boot.loader.ReLaunchURLClassLoader cannot be cast to com.taobao.pandora.boot.loader.ReLaunchURLClassLoader
...
```

原因是由于`Application.class.getClassLoader();`获取到的ReLaunchURLClassLoader对象，该对象的类加载器是AppClassLoader，__而出现在类型声明以及转型中的ReLaunchURLClassLoader则是由该获取到的ReLaunchURLClassLoader对象加载的（比较绕）__。因此转型是失败的，由此可见，类型转换也会在类加载器提供的命名空间的保护下进行

进行如下修改即可
```java
package com.alibaba.middleware;

import com.taobao.pandora.boot.PandoraBootstrap;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.lang.reflect.Field;
import java.util.Map;

/**
 * Pandora Boot应用的入口类
 *
 * @author chengxu
 */
@SpringBootApplication(scanBasePackages = {"com.alibaba.middleware"})
public class Application {

    public static void main(String[] args) throws Exception {
        PandoraBootstrap.run(args);

        // start
        ClassLoader reLaunchURLClassLoader = Application.class.getClassLoader();
        Field classCacheField = reLaunchURLClassLoader.getClass().getSuperclass().getDeclaredField("classCache");
        classCacheField.setAccessible(true);
        Map<String, Class<?>> classCache = (Map<String, Class<?>>) classCacheField.get(reLaunchURLClassLoader);
        System.err.println("success!");
        // end

        SpringApplication.run(Application.class, args);
        PandoraBootstrap.markStartupAndWait();
    }
}
```
