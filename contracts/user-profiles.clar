;; User Profiles Contract

;; Constants
(define-constant err-not-found (err u100))

;; Data Types
(define-map profiles
  { user: principal }
  {
    name: (string-ascii 50),
    bio: (string-utf8 500),
    recipes-created: uint,
    followers: uint
  }
)

(define-map following 
  { follower: principal, following: principal } 
  { active: bool }
)

;; Public Functions
(define-public (create-profile (name (string-ascii 50)) (bio (string-utf8 500)))
  (map-insert profiles
    { user: tx-sender }
    {
      name: name,
      bio: bio,
      recipes-created: u0,
      followers: u0
    }
  )
  (ok true)
)

(define-public (follow-user (user principal))
  (map-set following
    { follower: tx-sender, following: user }
    { active: true }
  )
  (let ((profile (unwrap! (map-get? profiles {user: user}) (err err-not-found))))
    (map-set profiles
      { user: user }
      (merge profile {
        followers: (+ (get followers profile) u1)
      })
    )
    (ok true)
  )
)
