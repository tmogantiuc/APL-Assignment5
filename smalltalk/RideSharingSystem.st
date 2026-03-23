"─── Helper: safe float formatting ─────────"
Object subclass: #FmtHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'RideSharingSystem'!

!FmtHelper class methodsFor: 'formatting'!
dollars: aNumber
    "Format a number as $XX.XX"
    | cents dollars centsStr |
    cents := (aNumber * 100) rounded.
    dollars := cents // 100.
    cents := cents \\ 100.
    centsStr := cents printString.
    (centsStr size < 2) ifTrue: [ centsStr := '0', centsStr ].
    ^ '$', dollars printString, '.', centsStr.
!

decimal: aNumber places: n
    "Format a float safely as string with n decimal places"
    | factor whole frac fracStr |
    factor := 10 raisedTo: n.
    whole := (aNumber * factor) rounded.
    frac := whole \\ factor.
    whole := whole // factor.
    fracStr := frac printString.
    [ fracStr size < n ] whileTrue: [ fracStr := '0', fracStr ].
    ^ whole printString, '.', fracStr.
! !

"─── Base Class: Ride ───────────────────────"
Object subclass: #Ride
    instanceVariableNames: 'rideID pickupLocation dropoffLocation distance calculatedFare'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'RideSharingSystem'!

!Ride methodsFor: 'initialization'!
initWithID: anID pickup: aPickup dropoff: aDropoff distance: aDist
    rideID := anID.
    pickupLocation := aPickup.
    dropoffLocation := aDropoff.
    distance := aDist.
    calculatedFare := 0.
! !

!Ride methodsFor: 'accessing'!
getRideID
    ^ rideID.
!

getFare
    ^ calculatedFare.
!

getDistance
    ^ distance.
! !

!Ride methodsFor: 'operations'!
fare
    "Subclasses must override — polymorphism"
    self subclassResponsibility.
!

rideType
    self subclassResponsibility.
!

rideDetails
    ('  Ride ID       : ', rideID printString) displayNl.
    ('  Pickup        : ', pickupLocation) displayNl.
    ('  Dropoff       : ', dropoffLocation) displayNl.
    ('  Distance      : ', (FmtHelper decimal: distance places: 1), ' miles') displayNl.
    ('  Fare          : ', (FmtHelper dollars: calculatedFare)) displayNl.
! !

"─── Derived Class: StandardRide ───────────"
Ride subclass: #StandardRide
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'RideSharingSystem'!

!StandardRide methodsFor: 'operations'!
fare
    calculatedFare := 2.00 + (1.50 * distance).
    ^ calculatedFare.
!

rideType
    ^ 'Standard'.
!

rideDetails
    '[ Standard Ride ]' displayNl.
    super rideDetails.
    '  Rate          : $1.50/mile + $2.00 base' displayNl.
! !

"─── Derived Class: PremiumRide ────────────"
Ride subclass: #PremiumRide
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'RideSharingSystem'!

!PremiumRide methodsFor: 'operations'!
fare
    calculatedFare := 5.00 + (3.00 * distance).
    ^ calculatedFare.
!

rideType
    ^ 'Premium'.
!

rideDetails
    '[ Premium Ride ]' displayNl.
    super rideDetails.
    '  Rate          : $3.00/mile + $5.00 base' displayNl.
! !

"─── Driver Class (encapsulation: assignedRides is private) ──────────"
Object subclass: #Driver
    instanceVariableNames: 'driverID name rating assignedRides'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'RideSharingSystem'!

!Driver methodsFor: 'initialization'!
initWithID: anID name: aName rating: aRating
    driverID := anID.
    name := aName.
    rating := aRating.
    assignedRides := OrderedCollection new.
! !

!Driver methodsFor: 'operations'!
addRide: aRide
    assignedRides add: aRide.
!

getDriverInfo
    '===== Driver Info =====' displayNl.
    ('  Driver ID     : ', driverID printString) displayNl.
    ('  Name          : ', name) displayNl.
    ('  Rating        : ', (FmtHelper decimal: rating places: 1), ' / 5.0') displayNl.
    ('  Completed Rides: ', assignedRides size printString) displayNl.
    assignedRides do: [ :ride |
        '  -------------------------' displayNl.
        ride rideDetails.
    ].
    '' displayNl.
!

totalEarnings
    ^ assignedRides inject: 0 into: [ :sum :r | sum + r getFare ].
! !

"─── Rider Class (encapsulation: requestedRides is private) ───────────"
Object subclass: #Rider
    instanceVariableNames: 'riderID name requestedRides'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'RideSharingSystem'!

!Rider methodsFor: 'initialization'!
initWithID: anID name: aName
    riderID := anID.
    name := aName.
    requestedRides := OrderedCollection new.
! !

!Rider methodsFor: 'operations'!
requestRide: aRide
    aRide fare.
    requestedRides add: aRide.
!

viewRides
    '===== Rider Info =====' displayNl.
    ('  Rider ID      : ', riderID printString) displayNl.
    ('  Name          : ', name) displayNl.
    ('  Requested Rides: ', requestedRides size printString) displayNl.
    requestedRides do: [ :ride |
        '  -------------------------' displayNl.
        ride rideDetails.
    ].
    '' displayNl.
!

totalSpent
    ^ requestedRides inject: 0 into: [ :sum :r | sum + r getFare ].
! !

"─── System Demo ───────────────────────────"
| r1 r2 r3 r4 allRides driver1 rider1 |

'============================================' displayNl.
'       RIDE SHARING SYSTEM (Smalltalk)      ' displayNl.
'============================================' displayNl.
'' displayNl.

r1 := StandardRide new initWithID: 101 pickup: 'Downtown'    dropoff: 'Airport'      distance: 12.5.
r2 := PremiumRide  new initWithID: 102 pickup: 'Mall'        dropoff: 'University'   distance: 8.0.
r3 := StandardRide new initWithID: 103 pickup: 'Park Ave'    dropoff: 'City Center'  distance: 5.3.
r4 := PremiumRide  new initWithID: 104 pickup: 'Hotel Grand' dropoff: 'Beach Resort' distance: 15.0.

allRides := OrderedCollection new.
allRides add: r1.
allRides add: r2.
allRides add: r3.
allRides add: r4.

'--- Polymorphic Fare Calculation ---' displayNl.
allRides do: [ :ride |
    | f |
    f := ride fare.
    ('  Ride ', ride getRideID printString,
        ' (', ride rideType, '): ', (FmtHelper dollars: f)) displayNl.
].
'' displayNl.

'--- Polymorphic Ride Details ---' displayNl.
allRides do: [ :ride |
    ride rideDetails.
    '' displayNl.
].

driver1 := Driver new initWithID: 1 name: 'Alice Johnson' rating: 4.8.
driver1 addRide: r1.
driver1 addRide: r2.
driver1 getDriverInfo.
('  Total Earnings: ', (FmtHelper dollars: driver1 totalEarnings)) displayNl.
'' displayNl.

rider1 := Rider new initWithID: 1 name: 'Bob Smith'.
rider1 requestRide: r3.
rider1 requestRide: r4.
rider1 viewRides.
('  Total Spent   : ', (FmtHelper dollars: rider1 totalSpent)) displayNl.
'' displayNl.

'============================================' displayNl.
'              END OF DEMO                   ' displayNl.
'============================================' displayNl.
!
