#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <iomanip>

using namespace std;

// ─── Base Class: Ride ───────────────────────────────────────────────
class Ride {
protected:
    int rideID;
    string pickupLocation;
    string dropoffLocation;
    double distance; // in miles
    double calculatedFare;

public:
    Ride(int id, const string& pickup, const string& dropoff, double dist)
        : rideID(id), pickupLocation(pickup), dropoffLocation(dropoff),
          distance(dist), calculatedFare(0.0) {}

    virtual ~Ride() = default;

    // Pure virtual — forces subclasses to provide their own fare logic
    virtual double fare() = 0;

    virtual void rideDetails() const {
        cout << "  Ride ID       : " << rideID << endl;
        cout << "  Pickup        : " << pickupLocation << endl;
        cout << "  Dropoff       : " << dropoffLocation << endl;
        cout << "  Distance      : " << distance << " miles" << endl;
        cout << "  Fare          : $" << fixed << setprecision(2) << calculatedFare << endl;
    }

    int getRideID() const { return rideID; }
    double getDistance() const { return distance; }
    double getFare() const { return calculatedFare; }
    virtual string rideType() const = 0;
};

// ─── Derived Class: StandardRide ────────────────────────────────────
class StandardRide : public Ride {
    static constexpr double RATE_PER_MILE = 1.50;
    static constexpr double BASE_FARE = 2.00;

public:
    StandardRide(int id, const string& pickup, const string& dropoff, double dist)
        : Ride(id, pickup, dropoff, dist) {}

    double fare() override {
        calculatedFare = BASE_FARE + (RATE_PER_MILE * distance);
        return calculatedFare;
    }

    void rideDetails() const override {
        cout << "[ Standard Ride ]" << endl;
        Ride::rideDetails();
        cout << "  Rate          : $" << RATE_PER_MILE << "/mile + $"
             << BASE_FARE << " base" << endl;
    }

    string rideType() const override { return "Standard"; }
};

// ─── Derived Class: PremiumRide ─────────────────────────────────────
class PremiumRide : public Ride {
    static constexpr double RATE_PER_MILE = 3.00;
    static constexpr double BASE_FARE = 5.00;

public:
    PremiumRide(int id, const string& pickup, const string& dropoff, double dist)
        : Ride(id, pickup, dropoff, dist) {}

    double fare() override {
        calculatedFare = BASE_FARE + (RATE_PER_MILE * distance);
        return calculatedFare;
    }

    void rideDetails() const override {
        cout << "[ Premium Ride ]" << endl;
        Ride::rideDetails();
        cout << "  Rate          : $" << RATE_PER_MILE << "/mile + $"
             << BASE_FARE << " base" << endl;
    }

    string rideType() const override { return "Premium"; }
};

// ─── Driver Class (encapsulation: assignedRides is private) ─────────
class Driver {
private:
    int driverID;
    string name;
    double rating;
    vector<shared_ptr<Ride>> assignedRides; // private — encapsulation

public:
    Driver(int id, const string& n, double r)
        : driverID(id), name(n), rating(r) {}

    void addRide(shared_ptr<Ride> ride) {
        assignedRides.push_back(ride);
    }

    void getDriverInfo() const {
        cout << "===== Driver Info =====" << endl;
        cout << "  Driver ID     : " << driverID << endl;
        cout << "  Name          : " << name << endl;
        cout << "  Rating        : " << rating << " / 5.0" << endl;
        cout << "  Completed Rides: " << assignedRides.size() << endl;
        for (const auto& ride : assignedRides) {
            cout << "  -------------------------" << endl;
            ride->rideDetails();
        }
        cout << endl;
    }

    double totalEarnings() const {
        double total = 0;
        for (const auto& r : assignedRides) total += r->getFare();
        return total;
    }
};

// ─── Rider Class ────────────────────────────────────────────────────
class Rider {
private:
    int riderID;
    string name;
    vector<shared_ptr<Ride>> requestedRides; // private — encapsulation

public:
    Rider(int id, const string& n) : riderID(id), name(n) {}

    void requestRide(shared_ptr<Ride> ride) {
        ride->fare(); // calculate fare when ride is requested
        requestedRides.push_back(ride);
    }

    void viewRides() const {
        cout << "===== Rider Info =====" << endl;
        cout << "  Rider ID      : " << riderID << endl;
        cout << "  Name          : " << name << endl;
        cout << "  Requested Rides: " << requestedRides.size() << endl;
        for (const auto& ride : requestedRides) {
            cout << "  -------------------------" << endl;
            ride->rideDetails();
        }
        cout << endl;
    }

    double totalSpent() const {
        double total = 0;
        for (const auto& r : requestedRides) total += r->getFare();
        return total;
    }
};

// ─── Main: System Functionality ─────────────────────────────────────
int main() {
    cout << "============================================" << endl;
    cout << "       RIDE SHARING SYSTEM (C++)            " << endl;
    cout << "============================================" << endl << endl;

    // --- Create rides of different types ---
    auto r1 = make_shared<StandardRide>(101, "Downtown",    "Airport",     12.5);
    auto r2 = make_shared<PremiumRide> (102, "Mall",        "University",   8.0);
    auto r3 = make_shared<StandardRide>(103, "Park Ave",    "City Center",  5.3);
    auto r4 = make_shared<PremiumRide> (104, "Hotel Grand", "Beach Resort",15.0);

    // --- Polymorphism: store mixed types in one collection ---
    vector<shared_ptr<Ride>> allRides = { r1, r2, r3, r4 };

    cout << "--- Polymorphic Fare Calculation ---" << endl;
    for (auto& ride : allRides) {
        double f = ride->fare();  // polymorphic call
        cout << "  Ride " << ride->getRideID()
             << " (" << ride->rideType() << "): $"
             << fixed << setprecision(2) << f << endl;
    }
    cout << endl;

    cout << "--- Polymorphic Ride Details ---" << endl;
    for (const auto& ride : allRides) {
        ride->rideDetails();  // polymorphic call
        cout << endl;
    }

    // --- Driver demo ---
    Driver driver1(1, "Alice Johnson", 4.8);
    driver1.addRide(r1);
    driver1.addRide(r2);
    driver1.getDriverInfo();
    cout << "  Total Earnings: $" << fixed << setprecision(2)
         << driver1.totalEarnings() << endl << endl;

    // --- Rider demo ---
    Rider rider1(1, "Bob Smith");
    rider1.requestRide(r3);
    rider1.requestRide(r4);
    rider1.viewRides();
    cout << "  Total Spent   : $" << fixed << setprecision(2)
         << rider1.totalSpent() << endl << endl;

    cout << "============================================" << endl;
    cout << "              END OF DEMO                   " << endl;
    cout << "============================================" << endl;

    return 0;
}
