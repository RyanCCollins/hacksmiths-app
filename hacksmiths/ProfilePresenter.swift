//
//  ProfilePresenter.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/24/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//


/** Protocol for following the MVP pattern
 */
protocol ProfileView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func setActivityIndicator(withMessage message: String?)
    func didUpdateUserData(didSucceed: Bool, error: NSError?)
    func didGetUserDataFromAPI(userData: UserData?, error: NSError?)
    func didLoadCachedUserData(userData: UserData?, error: NSError?)
}

/** Profile presenter - the presenter communicates with the model and updates the view
 */
class ProfilePresenter {
    private var profileView: ProfileView?
    private var userProfileService: UserProfileService
    
    init(userProfileService: UserProfileService) {
        self.userProfileService = userProfileService
    }
    
    func attachView(profileView: ProfileView) {
        self.profileView = profileView
        profileView.setActivityIndicator(withMessage: "Synching")
    }
    
    func detachView(profileView: ProfileView) {
        self.profileView = nil
    }
    
    /** Submit User Data to the API
     *
     *  @param userData - the user data to be submit to the API
     *  @return None
     */
    func submitDataToAPI(userData: UserData) {
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didUpdateUserData(false, error: GlobalErrors.BadCredentials)
            return
        }

        profileView?.startLoading()
        let userJSON = UserJSONObject(userData: userData)
        userProfileService.updateProfile(userJSON, userID: UserService.sharedInstance().userId!).then() {
            Void in
            self.profileView?.didUpdateUserData(true, error: nil)
            }.error {
                error in
                self.profileView?.didUpdateUserData(false, error: error as NSError)
        }
    }
    
    /** Fetch cached data for the profile view, so that it loads faster when possible
     *
     *  @param None
     *  @return None
     */
    func fetchCachedData() {
        /* Ensure that user is authenticated before loading cached data*/
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didLoadCachedUserData(nil, error: nil)
            return
        }
        
        userProfileService.fetchSavedUserData().then() {
            userData -> () in
            if userData != nil {
                self.profileView?.didLoadCachedUserData(userData, error: nil)
            } else {
                print("Called did load cached data did not succeed")
                self.profileView?.didLoadCachedUserData(nil, error: nil)
            }
            }.error {error in
                self.profileView?.didLoadCachedUserData(nil, error: error as NSError)
            }
    }
    
    /** Fetch user data from the API and handle the model logic
     *
     *  @param None
     *  @return None
     */
    func fetchUserDataFromAPI() {
        guard UserService.sharedInstance().authenticated == true else {
            self.profileView?.didGetUserDataFromAPI(nil, error: GlobalErrors.BadCredentials)
            return
        }
        profileView?.startLoading()
        userProfileService.getProfile(UserService.sharedInstance().userId!).then(){
            userData -> () in
            userData?.fetchImages().then() {
                    self.profileView?.didGetUserDataFromAPI(userData, error: nil)
                }.error{error in
                    self.profileView?.didGetUserDataFromAPI(nil, error: error as NSError)
                }
        }.error {error in
            self.profileView?.didGetUserDataFromAPI(nil, error: error as NSError)
        }
    }
}
