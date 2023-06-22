---
title: Design-Pattern
date: 2017-07-02 23:01:51
tags: 
- 原创
categories: 
- Design pattern
---

**阅读更多**

<!--more-->

# 1 Overview

Here are some of the commonly used design patterns in Java:

* **Creational Patterns:**
    1. **Singleton Pattern**: Ensures that only one instance of a class is created throughout the application.
    1. **Factory Pattern**: Provides an interface for creating objects, but allows subclasses to decide which class to instantiate.
    1. **Abstract Factory Pattern**: Provides an interface for creating families of related or dependent objects without specifying their concrete classes.
    1. **Builder Pattern**: Separates the construction of complex objects from their representation, allowing the same construction process to create different representations.
    1. **Prototype Pattern**: Creates objects by cloning existing ones, providing a way to create new instances without explicitly invoking a constructor.
* **Structural Patterns:**
    1. **Adapter Pattern**: Converts the interface of a class into another interface that clients expect, allowing classes to work together that couldn't otherwise because of incompatible interfaces.
    1. **Bridge Pattern**: Decouples an abstraction from its implementation, allowing both to vary independently.
    1. **Composite Pattern**: Composes objects into tree structures, representing part-whole hierarchies. It lets clients treat individual objects and compositions uniformly.
    1. **Decorator Pattern**: Dynamically adds behaviors or responsibilities to objects without modifying their structure.
    1. **Proxy Pattern**: Provides a surrogate or placeholder for another object to control access to it.
* **Behavioral Patterns:**
    1. **Observer Pattern**: Defines a one-to-many dependency between objects, so that when one object changes state, all its dependents are notified and updated automatically.
    1. **Strategy Pattern**: Defines a family of interchangeable algorithms, encapsulates each one, and makes them interchangeable within a context.
    1. **Template Method Pattern**: Defines the skeleton of an algorithm in a method, deferring some steps to subclasses.
    1. **Iterator Pattern**: Provides a way to access the elements of an aggregate object sequentially without exposing its underlying representation.
    1. **State Pattern**: Allows an object to alter its behavior when its internal state changes.
    1. **Chain of Responsibility Pattern**: Avoids coupling the sender of a request to its receiver by giving multiple objects a chance to handle the request.
    1. **Command Pattern**: Encapsulates a request as an object, thereby allowing users to parameterize clients with queues, requests, and operations.
    1. **Interpreter Pattern**: Defines a representation for a grammar or language and provides a way to interpret sentences in the language.
    1. **Mediator Pattern**: Defines an object that encapsulates how a set of objects interact, promoting loose coupling by keeping objects from referring to each other explicitly.
    1. **Visitor Pattern**: Defines a new operation to a class without changing the class itself.

# 2 Creational Patterns

## 2.1 Singleton Pattern

The Singleton Pattern is a creational design pattern that ensures a class has only one instance and provides a global point of access to that instance. This pattern is often used when there should be a single, shared instance of a class that needs to be accessed from various parts of the program.

**Examples:**

* case-1:
    ```java
    class Singleton{
        private static Singleton instance=new Singleton();
        
        private Singleton(){}
        
        public static Singleton getSingleton(){
            return instance;
        }
    }
    ```

* case-2
    ```java
    class Singleton{
        private static Singleton instance;

        private Singleton(){}

        public synchronized static Singleton getSingleton(){
            if(instance==null) {
                synchronized (Singleton.class) {
                    if (instance == null) {
                        instance = new Singleton();
                    }
                }
            }
            return instance;
        }
    }
    ```

* case-3
    ```java
    class Singleton{
        
        private static final class LazyInitialize{
            private static Singleton instance=new Singleton();
        }
        
        private Singleton(){}

        public static Singleton getSingleton(){
            return LazyInitialize.instance;
        }
    }
    ```

## 2.2 Factory Pattern

The Factory Pattern is a creational design pattern that provides an interface or base class for creating objects, but delegates the responsibility of determining the concrete type of object to the subclasses. It allows for the creation of objects without specifying their exact class, promoting loose coupling and flexibility in the code.

**Examples:**

```java
// Product interface
interface Vehicle {
    void drive();
}

// Concrete product classes
class Car implements Vehicle {
    @Override
    public void drive() {
        System.out.println("Driving a car.");
    }
}

class Motorcycle implements Vehicle {
    @Override
    public void drive() {
        System.out.println("Riding a motorcycle.");
    }
}

// Factory class
class VehicleFactory {
    public static Vehicle createVehicle(String type) {
        if (type.equalsIgnoreCase("car")) {
            return new Car();
        } else if (type.equalsIgnoreCase("motorcycle")) {
            return new Motorcycle();
        }
        return null; // Return null or throw an exception for unsupported types
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        Vehicle car = VehicleFactory.createVehicle("car");
        car.drive(); // Output: Driving a car.

        Vehicle motorcycle = VehicleFactory.createVehicle("motorcycle");
        motorcycle.drive(); // Output: Riding a motorcycle.
    }
}
```

In this example, we have an interface `Vehicle` that defines the common behavior of different types of vehicles. The `Car` and `Motorcycle` classes implement this interface and provide their own implementations of the `drive()` method.

The `VehicleFactory` class acts as the factory, providing a static method `createVehicle()` that takes a type parameter. Based on the type provided, it creates and returns the corresponding concrete `Vehicle` object. In this case, it creates either a `Car` or a `Motorcycle` object.

In the `Main` class, we can use the `VehicleFactory` to create instances of vehicles without directly instantiating concrete classes. This promotes flexibility because we can easily extend the factory to create new types of vehicles by adding new classes without modifying the client code.

By using the Factory Pattern, we decouple the client code from the concrete classes, allowing for easier maintenance, code extensibility, and testability.

## 2.3 Abstract Factory Pattern

The Abstract Factory Pattern is a creational design pattern that provides an interface or abstract class for creating families of related or dependent objects without specifying their concrete classes. It is an extension of the Factory Pattern, where multiple factories are grouped together under an abstract factory, allowing the creation of related objects as a family.

**Examples:**

```java
// Abstract product A
interface Window {
    void open();
}

// Concrete product A1
class WindowsWindow implements Window {
    @Override
    public void open() {
        System.out.println("Opening a Windows window.");
    }
}

// Concrete product A2
class MacWindow implements Window {
    @Override
    public void open() {
        System.out.println("Opening a Mac window.");
    }
}

// Abstract product B
interface Button {
    void click();
}

// Concrete product B1
class WindowsButton implements Button {
    @Override
    public void click() {
        System.out.println("Clicking a Windows button.");
    }
}

// Concrete product B2
class MacButton implements Button {
    @Override
    public void click() {
        System.out.println("Clicking a Mac button.");
    }
}

// Abstract factory
interface GUIFactory {
    Window createWindow();
    Button createButton();
}

// Concrete factory for Windows
class WindowsFactory implements GUIFactory {
    @Override
    public Window createWindow() {
        return new WindowsWindow();
    }

    @Override
    public Button createButton() {
        return new WindowsButton();
    }
}

// Concrete factory for Mac
class MacFactory implements GUIFactory {
    @Override
    public Window createWindow() {
        return new MacWindow();
    }

    @Override
    public Button createButton() {
        return new MacButton();
    }
}

// Client
public class Main {
    public static void main(String[] args) {
        // Create the factory for Windows
        GUIFactory windowsFactory = new WindowsFactory();
        // Use the factory to create Windows products
        Window windowsWindow = windowsFactory.createWindow();
        Button windowsButton = windowsFactory.createButton();

        windowsWindow.open();   // Output: Opening a Windows window.
        windowsButton.click();  // Output: Clicking a Windows button.

        // Create the factory for Mac
        GUIFactory macFactory = new MacFactory();
        // Use the factory to create Mac products
        Window macWindow = macFactory.createWindow();
        Button macButton = macFactory.createButton();

        macWindow.open();   // Output: Opening a Mac window.
        macButton.click();  // Output: Clicking a Mac button.
    }
}
```

In this example, we have two families of related products: `Window` and `Button`. Each family has multiple variations or implementations: `WindowsWindow` and `MacWindow` for the `Window` family, and `WindowsButton` and `MacButton` for the `Button` family.

The `GUIFactory` interface represents the abstract factory, declaring the methods `createWindow()` and `createButton()` for creating the respective products. The `WindowsFactory` and `MacFactory` classes are the concrete factories that implement the `GUIFactory` interface and provide the specific implementations of creating Windows or Mac products.

The client code uses the abstract factory (`GUIFactory`) to create the products without directly instantiating the concrete classes. The client code is decoupled from the specific product implementations and can work with any family of products created by the chosen factory.

The Abstract Factory Pattern promotes the creation of families of related objects in a unified and flexible manner. It allows for easy interchangeability of product families by simply switching the concrete factory, without affecting the client code that uses the products.

## 2.4 Builder Pattern

The Builder Pattern is a creational design pattern that provides a way to construct complex objects step by step. It separates the construction of an object from its representation, allowing the same construction process to create different representations of the object.

**Examples:**

```java
// Product class
class Car {
    private String make;
    private String model;
    private int year;
    private int doors;
    
    // Private constructor to enforce the use of the builder
    private Car() {
    }
    
    // Getters for the car properties
    
    public String getMake() {
        return make;
    }
    
    public String getModel() {
        return model;
    }
    
    public int getYear() {
        return year;
    }
    
    public int getDoors() {
        return doors;
    }
    
    // Builder class
    static class Builder {
        private String make;
        private String model;
        private int year;
        private int doors;
        
        // Setter methods for the car properties
        
        public Builder setMake(String make) {
            this.make = make;
            return this;
        }
        
        public Builder setModel(String model) {
            this.model = model;
            return this;
        }
        
        public Builder setYear(int year) {
            this.year = year;
            return this;
        }
        
        public Builder setDoors(int doors) {
            this.doors = doors;
            return this;
        }
        
        // Build method to create the Car object
        
        public Car build() {
            Car car = new Car();
            car.make = this.make;
            car.model = this.model;
            car.year = this.year;
            car.doors = this.doors;
            return car;
        }
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        Car car = new Car.Builder()
            .setMake("Toyota")
            .setModel("Camry")
            .setYear(2022)
            .setDoors(4)
            .build();
        
        System.out.println(car.getMake());   // Output: Toyota
        System.out.println(car.getModel());  // Output: Camry
        System.out.println(car.getYear());   // Output: 2022
        System.out.println(car.getDoors());  // Output: 4
    }
}
```

In this example, we have a `Car` class that represents a complex object to be constructed. The `Car` class has private properties for the make, model, year, and number of doors. It also has a private constructor to enforce the use of the builder for object creation.

The inner `Builder` class provides setter methods to set the different properties of the car. Each setter method returns the builder object itself (`this`) to support method chaining.

The `Builder` class also has a `build()` method that constructs and returns the final `Car` object. The `build()` method creates a new `Car` instance, sets the properties based on the values provided through the builder, and returns the constructed `Car` object.

In the `Main` class, we can use the builder to create a `Car` object by chaining the setter methods and finally calling the `build()` method. This allows us to construct a `Car` object step by step, setting only the desired properties.

The Builder Pattern provides a more readable and flexible way to create objects, especially when dealing with complex objects with many properties. It allows for the creation of different representations of the object by providing different builders or using optional setter methods in the builder.

## 2.5 Prototype Pattern

The Prototype Pattern is a creational design pattern that allows creating new objects by cloning or copying existing objects, known as prototypes. It provides a way to create objects without relying on traditional constructors, thus avoiding the need to explicitly instantiate classes.

**Examples:**

```java
// Prototype interface
interface Prototype {
    Prototype clone();
}

// Concrete prototypes
class ConcretePrototype1 implements Prototype {
    @Override
    public Prototype clone() {
        return new ConcretePrototype1();
    }
}

class ConcretePrototype2 implements Prototype {
    @Override
    public Prototype clone() {
        return new ConcretePrototype2();
    }
}

// Client
public class Main {
    public static void main(String[] args) {
        Prototype prototype1 = new ConcretePrototype1();
        Prototype clonedPrototype1 = prototype1.clone();
        
        Prototype prototype2 = new ConcretePrototype2();
        Prototype clonedPrototype2 = prototype2.clone();
        
        // Use the cloned prototypes as needed
    }
}
```

In this example, we have an interface `Prototype` that declares the `clone()` method, responsible for creating a copy of the prototype object. The concrete prototypes `ConcretePrototype1` and `ConcretePrototype2` implement this interface and provide their own implementations of the `clone()` method.

In the `Main` class, we create instances of the concrete prototypes `ConcretePrototype1` and `ConcretePrototype2`. To create a copy of a prototype, we simply call the `clone()` method on the prototype object, which returns a new instance of the same concrete prototype class.

By using the Prototype Pattern, we can create new objects by cloning existing objects, eliminating the need for complex instantiation logic. This pattern is particularly useful when creating objects that are costly to create or require initialization with a lot of data. It allows us to create new instances efficiently by copying the existing ones and then modifying them as needed.

It's worth noting that in Java, the `clone()` method is inherited from the `java.lang.Object` class. By implementing the `Cloneable` interface, you can use the built-in `clone()` method to create a shallow copy of an object. However, you may need to override the `clone()` method to perform a deep copy if the object contains mutable references.

# 3 Structural Patterns

## 3.1 Adapter Pattern

The Adapter Pattern is a structural design pattern that allows objects with incompatible interfaces to work together. It acts as a bridge between two incompatible interfaces, enabling them to collaborate and interact seamlessly.

**Examples:**

```java
// Target interface
interface MediaPlayer {
    void play(String audioType, String fileName);
}

// Adaptee class
class AdvancedMediaPlayer {
    void playVlc(String fileName) {
        System.out.println("Playing VLC file: " + fileName);
    }

    void playMp4(String fileName) {
        System.out.println("Playing MP4 file: " + fileName);
    }
}

// Adapter class
class MediaAdapter implements MediaPlayer {
    private AdvancedMediaPlayer advancedMediaPlayer;

    MediaAdapter(String audioType) {
        if (audioType.equalsIgnoreCase("vlc")) {
            advancedMediaPlayer = new AdvancedMediaPlayer();
        }
    }

    @Override
    public void play(String audioType, String fileName) {
        if (audioType.equalsIgnoreCase("vlc")) {
            advancedMediaPlayer.playVlc(fileName);
        }
    }
}

// Client
class AudioPlayer implements MediaPlayer {
    MediaAdapter mediaAdapter;

    @Override
    public void play(String audioType, String fileName) {
        if (audioType.equalsIgnoreCase("mp3")) {
            System.out.println("Playing MP3 file: " + fileName);
        } else if (audioType.equalsIgnoreCase("vlc")) {
            mediaAdapter = new MediaAdapter(audioType);
            mediaAdapter.play(audioType, fileName);
        } else {
            System.out.println("Invalid media type: " + audioType);
        }
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        AudioPlayer audioPlayer = new AudioPlayer();
        audioPlayer.play("mp3", "song.mp3");
        audioPlayer.play("vlc", "movie.vlc");
        audioPlayer.play("mp4", "video.mp4");
    }
}
```

In this example, we have a `MediaPlayer` interface that defines the target interface for playing audio files. The `AudioPlayer` class implements this interface and handles the playing of MP3 files directly.

The `AdvancedMediaPlayer` class is the existing class with its own interface for playing advanced audio formats like VLC and MP4.

The `MediaAdapter` class acts as an adapter, implementing the `MediaPlayer` interface while internally using the `AdvancedMediaPlayer` to handle the specific audio format.

The `AudioPlayer` class acts as the client and receives requests to play audio files. When it receives a request for an incompatible format (e.g., VLC), it creates an instance of the `MediaAdapter` specific to that format and delegates the play request to the adapter.

By using the Adapter Pattern, we can decouple the client (`AudioPlayer`) from the specific format of the audio being played (`AdvancedMediaPlayer`). The adapter allows the client to work with any audio format by adapting the requests to the appropriate methods of the `AdvancedMediaPlayer`.

In the example, when we play an MP3 file, the `AudioPlayer` handles it directly. When we play a VLC file, the `AudioPlayer` creates a `MediaAdapter` for VLC, which internally uses the `AdvancedMediaPlayer` to play the file.

The Adapter Pattern enables interaction between incompatible interfaces, making it easier to reuse existing classes and integrate them into new systems without modifying their original code.

## 3.2 Bridge Pattern

The Bridge Pattern is a structural design pattern that decouples an abstraction from its implementation, allowing both to vary independently. It provides a way to separate the interface (abstraction) and the implementation into separate class hierarchies, which can evolve independently of each other.

**Examples:**

```java
// Abstraction interface
interface Shape {
    void draw();
}

// Concrete implementation classes
class Circle implements Shape {
    private final String color;

    Circle(String color) {
        this.color = color;
    }

    @Override
    public void draw() {
        System.out.println("Drawing a " + color + " circle.");
    }
}

class Rectangle implements Shape {
    private final String color;

    Rectangle(String color) {
        this.color = color;
    }

    @Override
    public void draw() {
        System.out.println("Drawing a " + color + " rectangle.");
    }
}

// Implementor interface
interface Color {
    void applyColor();
}

// Concrete implementor classes
class RedColor implements Color {
    @Override
    public void applyColor() {
        System.out.println("Applying red color.");
    }
}

class BlueColor implements Color {
    @Override
    public void applyColor() {
        System.out.println("Applying blue color.");
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        Shape redCircle = new Circle("red");
        redCircle.draw();
        redCircle.applyColor();

        Shape blueRectangle = new Rectangle("blue");
        blueRectangle.draw();
        blueRectangle.applyColor();
    }
}
```

In this example, we have an abstraction hierarchy represented by the `Shape` interface. The `Circle` and `Rectangle` classes are concrete implementations of the `Shape` interface.

The `Color` interface represents the implementation hierarchy. The `RedColor` and `BlueColor` classes are concrete implementations of the `Color` interface.

The Bridge Pattern connects the abstraction and implementation hierarchies. The `Shape` interface has a reference to an instance of the `Color` interface. This way, the `Shape` can delegate the responsibility of applying the color to the specific `Color` implementation.

In the `Main` class, we create instances of concrete shapes (`Circle` and `Rectangle`) and associate them with specific colors (`RedColor` and `BlueColor`). We can call the `draw()` method on the shapes, which in turn calls the appropriate `draw()` method on the specific shape implementation. Similarly, the `applyColor()` method is called on the associated color implementation.

By using the Bridge Pattern, we separate the abstraction of shapes from their specific implementations and the application of colors from the specific color implementations. This allows for greater flexibility and extensibility, as we can easily add new shapes and colors independently without modifying existing classes.

The Bridge Pattern helps in achieving loose coupling between abstractions and implementations, enabling changes in one without affecting the other.

## 3.3 Composite Pattern

The Composite Pattern is a structural design pattern that allows you to compose objects into tree structures and represent part-whole hierarchies. It lets clients treat individual objects and compositions of objects uniformly.

**Examples:**

```java
// Component interface
interface Component {
    void render();
}

// Leaf class
class Leaf implements Component {
    private final String name;

    Leaf(String name) {
        this.name = name;
    }

    @Override
    public void render() {
        System.out.println("Rendering leaf: " + name);
    }
}

// Composite class
class Composite implements Component {
    private final List<Component> components = new ArrayList<>();

    void addComponent(Component component) {
        components.add(component);
    }

    void removeComponent(Component component) {
        components.remove(component);
    }

    @Override
    public void render() {
        System.out.println("Rendering composite:");
        for (Component component : components) {
            component.render();
        }
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        // Create leaf components
        Component leaf1 = new Leaf("Leaf 1");
        Component leaf2 = new Leaf("Leaf 2");

        // Create composite components
        Composite composite1 = new Composite();
        composite1.addComponent(leaf1);
        composite1.addComponent(leaf2);

        Component leaf3 = new Leaf("Leaf 3");
        Component leaf4 = new Leaf("Leaf 4");

        Composite composite2 = new Composite();
        composite2.addComponent(leaf3);
        composite2.addComponent(leaf4);

        // Create top-level composite
        Composite topLevelComposite = new Composite();
        topLevelComposite.addComponent(composite1);
        topLevelComposite.addComponent(composite2);

        // Render the top-level composite
        topLevelComposite.render();
    }
}
```

In this example, we have a `Component` interface that defines the common operations for both leaf objects (`Leaf`) and composite objects (`Composite`). The `Leaf` class represents the individual objects, while the `Composite` class represents the composite objects that can contain other components.

The `Composite` class contains a collection of `Component` objects and provides methods to add or remove components. The `render()` method in the `Composite` class recursively calls the `render()` method on each of its child components, resulting in a tree-like structure.

In the `Main` class, we create instances of leaf components (`Leaf`) and composite components (`Composite`). We add leaf components to composites and composites to other composites, forming a hierarchical structure.

When we call the `render()` method on the top-level composite, it internally calls the `render()` method on each component, resulting in the rendering of the entire component hierarchy.

The Composite Pattern allows clients to treat individual objects and compositions of objects uniformly. It simplifies the client's code as it doesn't need to distinguish between leaf objects and composite objects when operating on them. The pattern also enables the creation of complex structures by combining simple objects in a recursive manner.

The Composite Pattern is useful in scenarios where you need to represent part-whole hierarchies or tree-like structures, and you want to apply operations uniformly across individual objects and compositions.

## 3.4 Decorator Pattern

The Decorator Pattern is a structural design pattern that allows adding new behaviors or responsibilities to objects dynamically by wrapping them with decorator objects. It provides an alternative to subclassing for extending functionality.

**Examples:**

```java
// Component interface
interface Pizza {
    String getDescription();
    double getCost();
}

// Concrete component class
class Margherita implements Pizza {
    @Override
    public String getDescription() {
        return "Margherita Pizza";
    }

    @Override
    public double getCost() {
        return 5.99;
    }
}

// Decorator abstract class
abstract class PizzaDecorator implements Pizza {
    private final Pizza pizza;

    PizzaDecorator(Pizza pizza) {
        this.pizza = pizza;
    }

    @Override
    public String getDescription() {
        return pizza.getDescription();
    }

    @Override
    public double getCost() {
        return pizza.getCost();
    }
}

// Concrete decorator classes
class CheeseDecorator extends PizzaDecorator {
    CheeseDecorator(Pizza pizza) {
        super(pizza);
    }

    @Override
    public String getDescription() {
        return super.getDescription() + ", Extra Cheese";
    }

    @Override
    public double getCost() {
        return super.getCost() + 1.50;
    }
}

class MushroomDecorator extends PizzaDecorator {
    MushroomDecorator(Pizza pizza) {
        super(pizza);
    }

    @Override
    public String getDescription() {
        return super.getDescription() + ", Mushrooms";
    }

    @Override
    public double getCost() {
        return super.getCost() + 1.75;
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        // Create a Margherita pizza
        Pizza margherita = new Margherita();
        System.out.println(margherita.getDescription());  // Output: Margherita Pizza
        System.out.println(margherita.getCost());  // Output: 5.99

        // Add extra cheese to the Margherita pizza
        Pizza decoratedPizza = new CheeseDecorator(margherita);
        System.out.println(decoratedPizza.getDescription());  // Output: Margherita Pizza, Extra Cheese
        System.out.println(decoratedPizza.getCost());  // Output: 7.49

        // Add mushrooms to the decorated pizza
        decoratedPizza = new MushroomDecorator(decoratedPizza);
        System.out.println(decoratedPizza.getDescription());  // Output: Margherita Pizza, Extra Cheese, Mushrooms
        System.out.println(decoratedPizza.getCost());  // Output: 9.24
    }
}
```

In this example, we have a `Pizza` interface that defines the basic operations of a pizza, such as `getDescription()` and `getCost()`. The `Margherita` class is a concrete implementation of the `Pizza` interface.

The `PizzaDecorator` class is an abstract class that acts as the base decorator. It implements the same interface (`Pizza`) and holds a reference to a `Pizza` object. It delegates the calls to the wrapped pizza object, effectively adding functionality or modifying behavior.

The `CheeseDecorator` and `MushroomDecorator` classes are concrete decorators that extend the `PizzaDecorator` class. They add specific behaviors (extra cheese or mushrooms) to the decorated pizza by modifying the description and cost.

In the `Main` class, we create a `Margherita` pizza instance. We then wrap it with decorators (`CheeseDecorator` and `MushroomDecorator`) to add extra cheese and mushrooms to the pizza dynamically. The decorators modify the description and cost of the pizza, allowing for the dynamic addition of new features without modifying the original pizza class.

The Decorator Pattern provides a flexible and dynamic way to extend the functionality of objects without relying on subclassing. It promotes the principle of open-closed design, as new behaviors can be added by creating new decorator classes rather than modifying existing classes. It allows for the composition of objects with different behaviors at runtime.

## 3.5 Proxy Pattern

The Proxy Pattern is a structural design pattern that provides a surrogate or placeholder object, controlling access to another object. It allows for the creation of a representative object that can control the access, perform additional operations, or act as a protective layer for the underlying object.

**Examples:**

```java
// Subject interface
interface Image {
    void display();
}

// Real subject class
class RealImage implements Image {
    private final String filename;

    RealImage(String filename) {
        this.filename = filename;
        loadFromDisk();
    }

    private void loadFromDisk() {
        System.out.println("Loading image: " + filename);
    }

    @Override
    public void display() {
        System.out.println("Displaying image: " + filename);
    }
}

// Proxy class
class ImageProxy implements Image {
    private RealImage realImage;
    private final String filename;

    ImageProxy(String filename) {
        this.filename = filename;
    }

    @Override
    public void display() {
        if (realImage == null) {
            realImage = new RealImage(filename);
        }
        realImage.display();
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        Image image1 = new ImageProxy("image1.jpg");
        image1.display();  // Image is loaded and displayed

        Image image2 = new ImageProxy("image2.jpg");
        image2.display();  // Image is loaded and displayed

        // Image is not loaded until display() is called
        Image image3 = new ImageProxy("image3.jpg");
        // ...
        // Other operations
        // ...
        image3.display();  // Image is loaded and displayed
    }
}
```

In this example, we have an `Image` interface that represents the subject. The `RealImage` class is the real subject that performs the actual loading and displaying of an image.

The `ImageProxy` class acts as a proxy for the `RealImage`. It implements the `Image` interface and has a reference to a `RealImage` object. When the `display()` method is called on the proxy, it checks if the real image has been loaded. If not, it creates a `RealImage` instance and then calls the `display()` method on it.

In the `Main` class, we use the proxy to control access to the real image objects. When we call the `display()` method on the proxy, it dynamically creates the real image if necessary and delegates the display operation to it.

The Proxy Pattern is useful in various scenarios, such as lazy loading of resources, access control, caching, or adding additional functionality around an object. It allows for transparent access to the underlying object by providing a surrogate with the same interface.

In the example, the proxy delays the creation of the real image until it is actually needed, improving performance by loading images on demand. It acts as a protective layer, allowing the client to work with the proxy without directly interacting with the real image until necessary.

# 4 Behavioral Patterns

## 4.1 Observer Pattern

**Examples:**

```java
```

## 4.2 Strategy Pattern

**Examples:**

```java
```

## 4.3 Template Method Pattern

**Examples:**

```java
```

## 4.4 Iterator Pattern

**Examples:**

```java
```

## 4.5 State Pattern

**Examples:**

```java
```

## 4.6 Chain of Responsibility Pattern

**Examples:**

```java
```

## 4.7 Command Pattern

**Examples:**

```java
```

## 4.8 Interpreter Pattern

**Examples:**

```java
```

## 4.9 Mediator Pattern

**Examples:**

```java
```

## 4.10 Visitor Pattern

**Examples:**

```java
```
