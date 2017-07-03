# GuideWay

Bachelor's degree project. Implemented and released at the **NTUU "Kiev Polytechnic Institute"**.

----------------------

<img align="left" width="200"  src="https://github.com/KRUBERLICK/GuideWay/blob/master/Simulator%20Screen%20Shot%20Jul%203%2C%202017%2C%206.58.06%20PM.png"/>
<img align="left" width="200"  src="https://github.com/KRUBERLICK/GuideWay/blob/master/Simulator%20Screen%20Shot%20Jul%203%2C%202017%2C%206.58.11%20PM.png"/>
<img align="left" width="200"  src="https://github.com/KRUBERLICK/GuideWay/blob/master/Simulator%20Screen%20Shot%20Jul%203%2C%202017%2C%206.58.32%20PM.png"/>
<img align="left" width="200"  src="https://github.com/KRUBERLICK/GuideWay/blob/master/Simulator%20Screen%20Shot%20Jul%203%2C%202017%2C%206.58.46%20PM.png"/>

**GuideWay** is an interactive *instructional navigation application*, based on **GoogleMaps** services.

The app's main function is the ability to track user's progress on learning each created route with interactive quiz-like completion tests.

Start by creating a route within your city, complete the test and later you'll be able to freely navigate without the need to use your phone's navigation or any other navigator!

## Some technical info

A number of different third-party frameworks were used to accomplish this project. Among them are:

- **AsyncDisplayKit (Texture)** - implementing asynchronous user interfaces for the app
- **IGListKit** - *Instagram*'s library for working with `UICollectionView`'s updates and aliminate a number of problems caused by *data source - collection* view synchronization
- **DITranquillity** - for integrating the *Inversion of Control* principle
- **RxSwift/RxCocoa** - an implementation of *ReactiveX* for Swift language. Integrating all the benefits of *reactive programming* :)
- **Firebase/...** - numerous libraries for interacting with *Firebase* services, such an *Real-time Database*, *Firebase Storage* and so on
