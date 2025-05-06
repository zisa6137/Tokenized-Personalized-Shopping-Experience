;; Consumer Identity Contract
;; Manages shopper profiles on the blockchain

;; Data Variables
(define-map consumer-profiles
  { user-id: principal }
  {
    name: (string-utf8 100),
    email: (string-utf8 100),
    created-at: uint,
    active: bool
  }
)

;; Public Functions
(define-public (create-profile (name (string-utf8 100)) (email (string-utf8 100)))
  (let ((caller tx-sender))
    (if (is-some (map-get? consumer-profiles { user-id: caller }))
      (err u1) ;; Profile already exists
      (begin
        (map-set consumer-profiles
          { user-id: caller }
          {
            name: name,
            email: email,
            created-at: block-height,
            active: true
          }
        )
        (ok true)
      )
    )
  )
)

(define-public (update-profile (name (string-utf8 100)) (email (string-utf8 100)))
  (let ((caller tx-sender)
        (existing-profile (map-get? consumer-profiles { user-id: caller })))
    (if (is-none existing-profile)
      (err u2) ;; Profile doesn't exist
      (begin
        (map-set consumer-profiles
          { user-id: caller }
          {
            name: name,
            email: email,
            created-at: (get created-at (unwrap-panic existing-profile)),
            active: (get active (unwrap-panic existing-profile))
          }
        )
        (ok true)
      )
    )
  )
)

(define-public (deactivate-profile)
  (let ((caller tx-sender)
        (existing-profile (map-get? consumer-profiles { user-id: caller })))
    (if (is-none existing-profile)
      (err u2) ;; Profile doesn't exist
      (begin
        (map-set consumer-profiles
          { user-id: caller }
          {
            name: (get name (unwrap-panic existing-profile)),
            email: (get email (unwrap-panic existing-profile)),
            created-at: (get created-at (unwrap-panic existing-profile)),
            active: false
          }
        )
        (ok true)
      )
    )
  )
)

;; Read-only Functions
(define-read-only (get-profile (user-id principal))
  (map-get? consumer-profiles { user-id: user-id })
)

(define-read-only (is-profile-active (user-id principal))
  (let ((profile (map-get? consumer-profiles { user-id: user-id })))
    (if (is-some profile)
      (get active (unwrap-panic profile))
      false
    )
  )
)
