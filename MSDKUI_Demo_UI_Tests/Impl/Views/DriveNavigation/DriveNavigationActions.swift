//
// Copyright (C) 2017-2018 HERE Europe B.V.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import EarlGrey
@testable import MSDKUI
@testable import MSDKUI_Demo
import NMAKit
import XCTest

enum DriveNavigationActions {

    // MARK: - Types

    /// All the collected ETA data.
    struct ETAData {
        let eta: String
        let tta: String
        let distance: String
    }

    // MARK: - Public

    /// Dismisses alert if displayed on top.
    static func dismissAlert() {
        let permissionAlertElement = grey_accessibilityID("LocationBasedViewController.AlertController.permissionsView")

        Utils.waitUntil(visible: permissionAlertElement)
        EarlGrey.selectElement(with: permissionAlertElement).perform(
            GREYActionBlock.action(withName: "dismissAlert") { element, errorOrNil -> Bool in
                // Check error, make sure we have view here, and make sure this is alert controller view
                guard
                    errorOrNil != nil,
                    let alertView = element as? UIView,
                    let alert = alertView.viewController as? UIAlertController else {
                        return false
                }

                // Dismiss alert
                alert.dismiss(animated: false)

                return true
            }
        )
    }

    /// Taps the specified button after waiting for the specified alert visible.
    ///
    /// - Parameters:
    ///     - title: Text of the button that needs to be selected.
    static func selecActionOnSimulationAlert(button title: String) {
        let simulationAlert = grey_accessibilityID("GuidancePresentingViewController.AlertController.showSimulationView")

        Utils.waitUntil(visible: simulationAlert)
        EarlGrey.selectElement(with: simulationAlert).perform(
            GREYActionBlock.action(withName: "Select Alert Action \(title)") { _, errorOrNil -> Bool in
                guard errorOrNil != nil else {
                    return false
                }

                EarlGrey.selectElement(with: grey_text(title)).perform(grey_tap())

                return true
            }
        )
    }

    /// Checks that basic elements are visible in route overview view
    static func checkRouteOverviewElementsAreVisible() {
        EarlGrey.selectElement(with: CoreMatchers.backButton).assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: RouteOverviewMatchers.startNavigationButton)
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: DriveNavigationMatchers.driveNavMapView).assert(grey_sufficientlyVisible())
    }

    /// Verifies that waypoint map view is visible
    static func verifyWaypointMapViewWithNoDestinationIsVisible() {
        EarlGrey.selectElement(with: WaypointMatchers.waypointMapView)
            .assert(grey_sufficientlyVisible())
        EarlGrey.selectElement(with: Utils.viewContainingText(TestStrings.tapTheMapToSetYourDestination))
            .assert(grey_sufficientlyVisible())
    }

    /// Taps on the map view at the specified point and sets the destination.
    ///
    /// - Parameters:
    ///   - gesture: Gesture type like tap or long press.
    ///   - screenPoint: Point on the map view to tap.
    static func setDestination(with gesture: CoreActions.Gestures, screenPoint: CGPoint = CGPoint(x: 110.0, y: 110.0)) {
        // Drive navigation and map view is shown.
        verifyWaypointMapViewWithNoDestinationIsVisible()

        // Longtap anywhere on the map
        // Tap anywhere on the map
        switch gesture {
        case .tap:
            CoreActions.tap(element: WaypointMatchers.waypointMapView, point: screenPoint)
        case .longPress:
            CoreActions.longPress(element: WaypointMatchers.waypointMapView, point: screenPoint)
        }

        // Destination marker appears on the map and location address is shown
        // Negative assertion is done, to avoid location changes
        EarlGrey.selectElement(with: Utils.viewContainingText(TestStrings.tapOrLongPressOnTheMap))
            .assert(grey_notVisible())
    }

    /// Checks if correct maneuvers are displayed during simulation.
    ///
    /// - Parameters:
    ///     - maneuvers: Maneuvers that should be displayed (e.g. from `collectManeuversData`).
    ///     - isLandscape: if `true`, test will be performed in landscape, if `false` - in portrait.
    static func checkDisplayedManeuversDuringSimulation(maneuvers: [(address: String, iconAccessibilityIdentifier: String)],
                                                        isLandscape: Bool) {
        // For every instruction
        for step in 0..<maneuvers.count {
            // Check every step from maneuvers data.
            // 1. Wait for correct address to be displayed
            // 2. When displayed, check if displayed icon is correct

            // Check if address is correct
            let addressCondition = GREYCondition(name: "Wait for correct address") {
                var address = ""
                // Get view address label
                EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverViewText)
                    .atIndex(2)
                    .perform(
                        GREYActionBlock.action(withName: "Get description list") { element, errorOrNil -> Bool in
                            guard
                                errorOrNil != nil,
                                let label = element as? UILabel,
                                let labelText = label.text else {
                                    return false
                            }

                            // Get address text
                            address = labelText
                            return true
                        }
                )

                // Check is displayed address is the same as in maneuvers list
                return maneuvers[step].address == address
            }

            // Wait until correct address will be visible
            addressCondition.wait(withTimeout: 120, pollInterval: 1)

            // When address is correct, check if correct icon is displayed
            // Since we are using 2 sets of views - one for portrait, one for landscape,
            // both icons are in hierarchy, but different index is visible
            let iconElementIndex: UInt = isLandscape ? 1 : 0
            EarlGrey.selectElement(with: grey_allOf([grey_accessibilityID(maneuvers[step].iconAccessibilityIdentifier),
                                                     grey_ancestor(DriveNavigationMatchers.maneuverView)]))
                .atIndex(iconElementIndex)
                .assert(grey_sufficientlyVisible())
        }
    }

    /// Waits until simulation ends with arrival to destination.
    ///
    /// - Important: Arrival trigger is that the address color changes to .colorAccentLight
    ///              when destination is reached.
    static func waitForArrival() {
        let timeOut: Double = 180
        let condition = GREYCondition(name: "Wait for destination") {
            // Is the destination reached?
            getEstimatedArrivalLabelTextColor() == .colorAccentLight
        }.wait(withTimeout: timeOut, pollInterval: 1)

        GREYAssertTrue(condition, reason: "Destination was not reached after \(timeOut) seconds")
    }

    /// Returns a Boolean flag depending on destination is reached or not.
    ///
    /// - Returns: True if the destination reached and false otherwise.
    /// - Important: Arrival trigger is that the address color changes to .colorAccentLight
    ///              when destination is reached.
    static func hasArrived() -> Bool {
        var labelColor: UIColor?

        _ = GREYCondition(name: "Wait for label text color retrieval") {
            labelColor = getEstimatedArrivalLabelTextColor()

            // Make sure that a color is retrieved
            return labelColor != nil
        }.wait(withTimeout: Constants.shortWait, pollInterval: Constants.mediumPollInterval)

        // Is the destination reached?
        return labelColor == .colorAccentLight
    }

    /// This method checks if correct color is displayed on speedView.
    /// Red is expected for overspeeding and black for regular drive.
    ///
    /// - Parameters:
    ///     - isSpeeding: A Boolean value to assume whether overspeeding is taking place or not.
    static func verifySpeeding(isSpeeding: Bool) {
        var labelColor: UIColor?
        var viewBackgroundColor: UIColor?

        let timeOut = Constants.longWait
        let condition = GREYCondition(name: "Speed view must have correct color") {
            (labelColor, viewBackgroundColor) = getCurrentSpeedViewColor()

            switch isSpeeding {
            case true:
                return labelColor == .colorNegative || viewBackgroundColor == .colorNegative

            case false:
                return labelColor == .colorForeground || viewBackgroundColor == .colorBackgroundBrand
            }
        }.wait(withTimeout: timeOut, pollInterval: Constants.mediumPollInterval)

        GREYAssertTrue(condition, reason: "Correct color was not displayed after waiting for \(timeOut) seconds")
    }

    /// Helper method to adapt positioning data source update interval to EarlGrey framework.
    static func adaptSimulationToEarlGrey() {
        // Since updateInterval is too often, EarlGrey is not responding, assuming that application is not
        // in "idle state". We must change update interval in order to be able to work with application
        // during simulation.

        // Disable synchronization to avoid waiting for "application idle state"
        GREYConfiguration.sharedInstance().setValue(false, forConfigKey: kGREYConfigKeySynchronizationEnabled)

        // Wait until simulation data source is set in application
        let condition = GREYCondition(name: "Data source set") {

            // Check if data source is set and is our "simulation data source"
            return NMAPositioningManager.sharedInstance().dataSource is NMARoutePositionSource
        }
        let result = condition.wait(withTimeout: 5, pollInterval: 1)

        // Make sure we have correct data source
        GREYAssertTrue(result, reason: "Data source not set")

        // Configure data source with new update interval and speed - this will allow EarlGrey to proceed
        NMAPositioningManager.sharedInstance().stopPositioning()
        if let dataSource = NMAPositioningManager.sharedInstance().dataSource as? NMARoutePositionSource {
            dataSource.updateInterval = Constants.normalUpdateIntervalForEarlGrey
            dataSource.movementSpeed = Constants.normalSimulationSpeed
            NMAPositioningManager.sharedInstance().dataSource = dataSource
        }

        // Start positioning again
        NMAPositioningManager.sharedInstance().startPositioning()

        // Enable synchronization in order to work with application as usual
        GREYConfiguration.sharedInstance().setValue(true, forConfigKey: kGREYConfigKeySynchronizationEnabled)
    }

    /// Method for increasing simulation movement speed
    ///
    /// - Important: Doing heavy duty actions after this method has been called is unadvised as
    ///              it is already stretching the limits of EG, a timeout exception can occur.
    static func increaseSimulationMovementSpeed() {
        NMAPositioningManager.sharedInstance().stopPositioning()
        if let dataSource = NMAPositioningManager.sharedInstance().dataSource as? NMARoutePositionSource {
            dataSource.updateInterval = Constants.slowUpdateIntervalForEarlGrey
            dataSource.movementSpeed = Constants.fastSimulationSpeed
            NMAPositioningManager.sharedInstance().dataSource = dataSource
        }

        // Start positioning again
        NMAPositioningManager.sharedInstance().startPositioning()
    }

    /// Sleeps the main thread one minute.
    static func sleepMainThreadOneMinute() {
        GREYAssertTrue(Thread.isMainThread, reason: "The current thread is the main thread")

        Thread.sleep(until: Date(timeIntervalSinceNow: 60))
    }

    /// Sleeps the main thread for updates to occur when guidance is adapted to EarlGrey.
    static func sleepMainThreadUntilViewsUpdated() {
        GREYAssertTrue(Thread.isMainThread, reason: "The current thread is the main thread")

        Thread.sleep(until: Date(timeIntervalSinceNow: Constants.normalUpdateIntervalForEarlGrey + Double(1.0)))
    }

    /// This method retrieves the estimated arrival data from dashboard.
    ///
    /// - Returns: Estimated arrival time as a struct
    static func getEstimatedArrivalData() -> ETAData {
        var etaData = ETAData(eta: "", tta: "", distance: "")

        _ = GREYCondition(name: "Wait for ETA data") {
            EarlGrey.selectElement(with: DriveNavigationMatchers.arrivalTime).perform(
                GREYActionBlock.action(withName: "eta") { element, errorOrNil in
                    guard
                        errorOrNil != nil,
                        let arivalView = element as? GuidanceEstimatedArrivalView,
                        let eta = arivalView.estimatedTimeOfArrivalLabel?.text,
                        let tta = arivalView.durationLabel?.text,
                        let distance = arivalView.distanceLabel?.text else {
                            return false
                    }

                    etaData = ETAData(eta: eta, tta: tta, distance: distance)

                    return true
                }
            )

            return etaData.eta.isEmpty == false && etaData.tta.isEmpty == false && etaData.distance.isEmpty == false
        }.wait(withTimeout: Constants.shortWait, pollInterval: Constants.longPollInterval)

        print("Arrival data: ETA = \(etaData.eta), TTA = \(etaData.tta), Distance = \(etaData.distance)")

        GREYAssertTrue(etaData.eta.isEmpty == false && etaData.tta.isEmpty == false && etaData.distance.isEmpty == false,
                       reason: "the data is not retrieved")

        return etaData
    }

    // MARK: - Private

    /// This method retrieves the estimated arrival label text color.
    ///
    /// - Returns: Estimated arrival label text color.
    private static func getEstimatedArrivalLabelTextColor() -> UIColor? {
        var labelColor: UIColor?
        EarlGrey.selectElement(with: DriveNavigationMatchers.maneuverViewText)
            .atIndex(2)
            .perform(
                GREYActionBlock.action(withName: "Get label text color") { element, errorOrNil -> Bool in
                    guard
                        errorOrNil != nil,
                        let label = element as? UILabel else {
                            return false
                    }

                    labelColor = label.textColor
                    return true
                }
        )

        return labelColor
    }

    /// This method retrieves current speed view colors for label and background.
    ///
    /// - Returns: Speed view label and background color.
    private static func getCurrentSpeedViewColor() -> (UIColor?, UIColor?) {
        var labelColor: UIColor?
        var viewBackgroundColor: UIColor?

        EarlGrey.selectElement(with: DriveNavigationMatchers.currentSpeed)
            .atIndex(1)
            .perform(
                GREYActionBlock.action(withName: "Get label text color") { element, errorOrNil -> Bool in
                    guard
                        errorOrNil != nil,
                        let speedView = element as? GuidanceSpeedView else {
                            return false
                    }

                    labelColor = speedView.speedValueLabel.textColor
                    viewBackgroundColor = speedView.backgroundColor
                    return true
                }
        )

        return (labelColor, viewBackgroundColor)
    }
}