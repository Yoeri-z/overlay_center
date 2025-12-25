Show dialogs, toasts and bottom sheets, snackbars, modals and more from anywhere without "magic" decoupling from context.

# Getting started

Add the package to your project:
`flutter pub add overlay_center`

# Warning before usage

Overlay center "removes" the dependency on context for overlays, and provides a different method for testing.
Using this project me be convenient but once you are using it, it is very hard to refactor your code to not use it later on.

This warning is not here to discourage you from using the package but you should first think carefully if this is really what you want.
If your app depends a lot on dialogs and snackbars or toasts it defenitely recommend using it. If you only have a few dialogs, it is probably overkill.

# How it works

## Overlay Handler

Add an `OverlayHandler` widget directly below the scaffold of every page (or only the pages that show dialogs, sheets, toasts, etc.).

```dart
@override
Widget build(BuildContext context){
    return Scaffold(
        body: OverlayHandler(
            child: MyBody(),
        ),
    );
}
```

Note: `OverlayHandler` can actually be placed anywhere below the scaffold in the widget tree, but for consistency it is best to add it directly below the scaffold since it does not require anything else.

This handler will be handling (hence the name) any incoming overlay events, dialogs, bottom sheets, modals toasts, or something custom.
This handler is where the context comes from! This is very important to realize, the context does not magically dissapear, it is the context at the location of the handler. This is especially crucial to know if you want to implement a custom overlay widget.

## Overlay center

This is where you can create and show overlays, it works like this:

```dart
//Get the overlay instance from anywhere in your app
OverlayCenter get overlay => OverlayCenter.instance;


void aFunction(){
    //Show a toast on the currently active page, provided it has an OverlayHandler
    overlay.showToast(message: 'A Function was called', toastType: ToastType.succes);
}
```

The overlay center can display the following overlays:

```dart
overlay.showDialog(MyDialog())
//this package also provides a new overlay called toast
//easier to manage than snackbar or material banner
overlay.showToast(message: ..., toastType: ...)
overlay.showBottomSheet(MySheet())
overlay.showModalBottomSheet(MyModalSheet())
overlay.showCupertinoDialog(MyDialog())
overlay.showCupertinoModalPopup(MyModal())
overlay.showCupertinoSheet(MySheet())

//These are not really overlays but have a similar purpose so they are also available.
overlay.showSnackbar(Snackbar(...))
overlay.showMaterialBanner(MaterialBanner(...))

//these are lower level methods to create more complex or custom overlays
//overlay.request shows an overlay that can be popped with a value
overlay.request((context){
    throw UnimplementedError();
})
//overlay.raw can run anything and return anything, it just provides a builder with BuildContext as parameter (remember this context is the context of the OverlayHandler)
overlay.raw((context){
    throw UnimplementedError();
})
```

## Testing

Because overlay center somewhat decouples the overlay from the widget tree, it is also possible to do tests without actually running the flutter framework.

```dart
test('Example test', (){
    // create a test handler
    final handler = TestOverlayHandler([true, null]);

    // register this handler
    overlay.registerTestHandler(handler);

    //now the overlay will take the first item from the list passed to handler for each overlay event called, and return it instead of actually building the overlay.


    //This is really usefull when combined with state managers, Notifiers, Blocs or others can now show dialogs but still be tested without using the flutter framework.

    notifier.doSomething();
    expect(notifier.property, isSomething);
})
```

## Toasts

Toasts are a very popular modal in most desktop ui libraries,
this package adds an implementation of it.

To change the style of toasts across the app wrap the widget tree with a `ToastTheme` widget.
