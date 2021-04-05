---
title: Kubernetes-CRD-Demo
date: 2019-09-27 16:28:02
tags: 
- 原创
categories: 
- Kubernetes
---

**阅读更多**

<!--more-->

# 1 code-generator

`code-generator`根据我们定义的crd文件，来动态创建`kubernetes API`风格的`go`源码

## 1.1 示例工程结构

[demo-controller](https://github.com/liuyehcf/demo-controller)

```
.
├── artifacts
│   ├── crd.yaml
│   └── example-myconfig.yaml
├── go.mod
├── go.sum
├── hack
│   ├── boilerplate.go.txt
│   ├── custom-boilerplate.go.txt
│   ├── tools.go
│   ├── update-codegen.sh
│   └── verify-codegen.sh
├── main.go
└── pkg
    ├── apis
    │   └── democontroller
    │       └── v1
    │           ├── doc.go
    │           ├── register.go
    │           ├── types.go
    │           └── zz_generated.deepcopy.go
    └── generated
        ├── clientset ... 省略子目录以及文件
        ├── informers ... 省略子目录以及文件
        └── listers ... 省略子目录以及文件
```

* `artifacts`：该目录下包含crd以及对应资源的yaml文件
* `hack`：该目录下包含动态创建源码的脚本
* `pkg/apis`：**crd资源定义，这部分是本示例的关键**
    * 其中`zz_generated.deepcopy.go`文件是由`code-generator`创建的
* `generated`：该目录下的文件全部是由`code-generator`创建的

## 1.2 创建工程

利用`go module`创建模块（我用的go版本是`go1.13`，版本`go1.12`及以上均可）

`go mod init github.com/liuyehcf/demo-controller`

## 1.3 编写`pkg/api`

`code-generator`要求工程的目录结构满足一定的规则

* 目录结构必须为`pkg/apis/xxx/yyy/`
* 包含如下文件
    1. `doc.go`
    1. `register.go`
    1. `types.go`

### 1.3.1 `types.go`

```go
/*
Copyright 2017 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// MyConfig is a specification for a MyConfig resource
type MyConfig struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec MyConfigSpec `json:"spec"`
}

// MyConfigSpec is the spec for a MyConfig resource
type MyConfigSpec struct {
	ConfigName  string `json:"configName"`
	ConfigValue string `json:"configValue"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// MyConfigList is a list of MyConfig resources
type MyConfigList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata"`
	Items []MyConfig `json:"items"`
}
```

一般，在定义中都会包含`kubernetes`的标准字段，包括`metav1.TypeMeta`、`metav1.ObjectMeta`，通常我们需要定义的就是`Spec`这部分，对应上述示例中的`MyConfigSpec`

总结一下，如果我们定义的`CRD`的`Kind`为`XXX`，那么需要定义如下类型

1. `XXX`
1. `XXXSpec`
1. `XXXList`

**此外，注意一个`code-generator`的神坑，在上述源码中，包含了如下注释，这部分内容是`code-generator`的元数据，不写或写错都会导致代码生成失败，请注意！！！**

```go
// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
...
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
```

### 1.3.2 `doc.go`

```go
/*
Copyright 2017 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// +k8s:deepcopy-gen=package
// +groupName=democontroller.github.com.liuyehcf

// Package v1 is the v1 version of the API.
package v1 // import "github.com/liuyehcf/demo-controller/pkg/apis/democontroller/v1"
```

**这个文件乍一看就一个package声明，但是，注意上方两行注释，没有这两行注释，这部分内容是`code-generator`的元数据，不写或写错都会导致代码生成失败，请注意！！！**

```go
// +k8s:deepcopy-gen=package
// +groupName=democontroller.github.com.liuyehcf
```

### 1.3.3 `register.go`

```go
/*
Copyright 2017 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

// SchemeGroupVersion is group version used to register these objects
var SchemeGroupVersion = schema.GroupVersion{Group: "democontroller.github.com.liuyehcf", Version: "v1"}

// Kind takes an unqualified kind and returns back a Group qualified GroupKind
func Kind(kind string) schema.GroupKind {
	return SchemeGroupVersion.WithKind(kind).GroupKind()
}

// Resource takes an unqualified resource and returns a Group qualified GroupResource
func Resource(resource string) schema.GroupResource {
	return SchemeGroupVersion.WithResource(resource).GroupResource()
}

var (
	// SchemeBuilder initializes a scheme builder
	SchemeBuilder = runtime.NewSchemeBuilder(addKnownTypes)
	// AddToScheme is a global function that registers this API group & version to a scheme
	AddToScheme = SchemeBuilder.AddToScheme
)

// Adds the list of known types to Scheme.
func addKnownTypes(scheme *runtime.Scheme) error {
	scheme.AddKnownTypes(SchemeGroupVersion,
		&MyConfig{},
		&MyConfigList{},
	)
	metav1.AddToGroupVersion(scheme, SchemeGroupVersion)
	return nil
}
```

注意，`var SchemeGroupVersion = schema.GroupVersion{Group: "democontroller.github.com.liuyehcf", Version: "v1"}`这一句，`Group`的内容要与`doc.go`中的注释保持一致（`// +groupName=democontroller.github.com.liuyehcf`）

## 1.4 `hack`

这部分内容，我们直接从`kubernetes`官方示例（[sample-controller](https://github.com/kubernetes/sample-controller)）中拷贝即可

其中，`update-codegen.sh`文件需要稍作修改

首先，`CODEGEN_PKG=${CODEGEN_PKG:-$(cd "${SCRIPT_ROOT}"; ls -d -1 ./vendor/k8s.io/code-generator 2>/dev/null || echo ../code-generator)}`修改成`CODEGEN_PKG=${GOPATH}/src/k8s.io/code-generator`，确保环境变量`GOPATH`设置正确

其次，修改`generate-groups.sh`脚本执行时传入的参数（我们自定义的目录结构跟官方示例的肯定不同）

```
bash "${CODEGEN_PKG}"/generate-groups.sh "deepcopy,client,informer,lister" \
  k8s.io/sample-controller/pkg/generated k8s.io/sample-controller/pkg/apis \
  samplecontroller:v1alpha1 \
  --output-base "$(dirname "${BASH_SOURCE[0]}")/../../.." \
  --go-header-file "${SCRIPT_ROOT}"/hack/boilerplate.go.txt
```

改成

```
bash "${CODEGEN_PKG}"/generate-groups.sh "deepcopy,client,informer,lister" \
  github.com/liuyehcf/demo-controller/pkg/generated github.com/liuyehcf/demo-controller/pkg/apis \
  democontroller:v1 \
```

* `github.com/liuyehcf/demo-controller/pkg/generated`指的是输出的文件目录
* `github.com/liuyehcf/demo-controller/pkg/apis`指的是输入文件目录
* `democontroller:v1`就是工程目录结构`pkg/apis/xxx/yyy`中的`xxx/yyy`

## 1.5 执行脚本创建`pkg/generated`

在执行脚本前，我们需要先下载一个依赖的脚本，就是`update-codegen.sh`中提到的`generate-groups.sh`

```sh
cd $GOPATH
mkdir -p src/k8s.io
cd src/k8s.io
git clone https://github.com/kubernetes/code-generator.git
```

然后执行脚本

```sh
cd <工程目录>
bash hack/update-codegen.sh
```

输出如下

```
Generating deepcopy funcs
Generating clientset for democontroller:v1 at github.com/liuyehcf/demo-controller/pkg/generated/clientset
Generating listers for democontroller:v1 at github.com/liuyehcf/demo-controller/pkg/generated/listers
Generating informers for democontroller:v1 at github.com/liuyehcf/demo-controller/pkg/generated/informers
```

## 1.6 编写yaml文件

这里要编写的yaml文件与`types.go`中定义的数据结构一一对应

### 1.6.1 `crd.yaml`

```yaml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: myconfigs.democontroller.github.com.liuyehcf
spec:
  group: democontroller.github.com.liuyehcf
  version: v1
  names:
    kind: MyConfig
    plural: myconfigs
    singular: myconfig
  scope: Namespaced
```

**注意**

1. `metadata.name`的结构为`<spec.names.plural>.<spec.group>`
1. `spec.group`必须与`doc.go`中的注释，以及`register.go`中的`var SchemeGroupVersion = schema.GroupVersion...`保持一致
1. `spec.version`必须与`doc.go`的`package`，以及`register.go`中的`var SchemeGroupVersion = schema.GroupVersion...`保持一致
1. `spec.names.kind`必须与`types.go`中的类型名一致

### 1.6.2 `example-myconfig.yaml`

```yaml
apiVersion: democontroller.github.com.liuyehcf/v1
kind: MyConfig
metadata:
  name: example-myconfig
spec:
  configName: Country
  configValue: China
```

注意

1. `apiVersion`的格式为`crd.yaml`中的`<spec.group>/<spec.version>`
1. `kind`，必须与`crd.yaml`中的`spec.names.kind`保持一致
1. `spec`的属性值必须与`types.go`中的定义保持一致

## 1.7 main.go

```go
package main

import (
	"flag"
	"fmt"
	clientset "github.com/liuyehcf/demo-controller/pkg/generated/clientset/versioned"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/klog"
	// Uncomment the following line to load the gcp plugin (only required to authenticate against GKE clusters).
	// _ "k8s.io/client-go/plugin/pkg/client/auth/gcp"

)

var (
	masterURL  string
	kubeconfig string
)

func main() {
	//klog.InitFlags(nil)
	//flag.Parse()
	//
	//// set up signals so we handle the first shutdown signal gracefully
	//stopCh := signals.SetupSignalHandler()
	//
	//cfg, err := clientcmd.BuildConfigFromFlags(masterURL, kubeconfig)
	//if err != nil {
	//	klog.Fatalf("Error building kubeconfig: %s", err.Error())
	//}
	//
	//kubeClient, err := kubernetes.NewForConfig(cfg)
	//if err != nil {
	//	klog.Fatalf("Error building kubernetes clientset: %s", err.Error())
	//}
	//
	//exampleClient, err := clientset.NewForConfig(cfg)
	//if err != nil {
	//	klog.Fatalf("Error building example clientset: %s", err.Error())
	//}
	//
	//kubeInformerFactory := kubeinformers.NewSharedInformerFactory(kubeClient, time.Second*30)
	//exampleInformerFactory := informers.NewSharedInformerFactory(exampleClient, time.Second*30)
	//
	//controller := controllers.NewController(kubeClient, exampleClient,
	//	exampleInformerFactory.Democontroller().V1().MyConfigs())
	//
	//// notice that there is no need to run Start methods in a separate goroutine. (i.e. go kubeInformerFactory.Start(stopCh)
	//// Start method is non-blocking and runs all registered informers in a dedicated goroutine.
	//kubeInformerFactory.Start(stopCh)
	//exampleInformerFactory.Start(stopCh)
	//
	//if err = controller.Run(2, stopCh); err != nil {
	//	klog.Fatalf("Error running controller: %s", err.Error())
	//}

	klog.InitFlags(nil)
	flag.Parse()

	cfg, err := clientcmd.BuildConfigFromFlags(masterURL, kubeconfig)
	if err != nil {
		klog.Fatalf("Error building kubeconfig: %s", err.Error())
		return
	}

	exampleClient, err := clientset.NewForConfig(cfg)
	if err != nil {
		klog.Fatalf("Error building example clientset: %s", err.Error())
		return
	}

	myConfigList, err := exampleClient.DemocontrollerV1().MyConfigs("").List(metav1.ListOptions{})
	if err != nil {
		klog.Fatalf("Error listing myconfigs: %s", err.Error())
		return
	}

	fmt.Println(myConfigList)
}

func init() {
	flag.StringVar(&kubeconfig, "kubeconfig", "", "Path to a kubeconfig. Only required if out-of-cluster.")
	flag.StringVar(&masterURL, "master", "", "The address of the Kubernetes API server. Overrides any value in kubeconfig. Only required if out-of-cluster.")
}
```

## 1.8 测试

自行搭建一个k8s集群，这部分就不细讲了，可以参考{% post_link Kubernetes-Demo %}

```sh
kubectl create -f crd.yaml

kubectl create -f example-myconfig.yaml
```

执行main函数，可以看到获取到的crd资源详情

# 2 operator-framework

[安装operator-sdk](https://github.com/operator-framework/operator-sdk/blob/master/doc/user/install-operator-sdk.md)

1. 创建operator工程：`operator-sdk new operator-demo --repo=github.com/liuyehcf/operator-demo`
1. 创建api：`operator-sdk add api --api-version=liuyehcf.crd.person/v1 --kind=Person`
	* `--api-version`：指定api版本
	* `--kind`：资源名称，这里叫做`Person`
1. 修改`pkg/apis/liuyehcf/v1/person_types.go`
1. 生成对应的deepcopy等相关方法：`operator-sdk generate k8s`
1. 创建controller：`operator-sdk add controller --api-version=liuyehcf.crd.person/v1 --kind=Person`

## 2.1 operator-demo

# 3 参考

* [sample-controller](https://github.com/kubernetes/sample-controller)
* [operator](https://github.com/operator-framework/operator-sdk)
* [Operator SDK User Guide](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)
* [client-go-example](https://github.com/kubernetes/client-go/tree/master/examples)
* [使用client-go包访问Kubernetes CRD](https://segmentfault.com/a/1190000020437031)
* [Kubernetes CRD - 从代码生成到使用](https://www.jianshu.com/p/2884f002f055)
* [Operator SDK CLI reference](https://docs.openshift.com/container-platform/4.1/applications/operator_sdk/osdk-cli-reference.html)
