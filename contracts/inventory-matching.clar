;; Inventory Matching Contract
;; Connects consumers with relevant products

;; Data Variables
(define-map products
  { product-id: uint }
  {
    name: (string-utf8 100),
    category: (string-utf8 50),
    brand: (string-utf8 50),
    price: uint,
    available: bool
  }
)

(define-map product-matches
  { user-id: principal }
  { matched-products: (list 50 uint) }
)

(define-data-var next-product-id uint u1)

;; Public Functions
(define-public (add-product
                (name (string-utf8 100))
                (category (string-utf8 50))
                (brand (string-utf8 50))
                (price uint))
  (let ((product-id (var-get next-product-id)))
    (map-set products
      { product-id: product-id }
      {
        name: name,
        category: category,
        brand: brand,
        price: price,
        available: true
      }
    )
    (var-set next-product-id (+ product-id u1))
    (ok product-id)
  )
)

(define-public (update-product-availability (product-id uint) (available bool))
  (let ((existing-product (map-get? products { product-id: product-id })))
    (if (is-none existing-product)
      (err u1) ;; Product doesn't exist
      (begin
        (map-set products
          { product-id: product-id }
          {
            name: (get name (unwrap-panic existing-product)),
            category: (get category (unwrap-panic existing-product)),
            brand: (get brand (unwrap-panic existing-product)),
            price: (get price (unwrap-panic existing-product)),
            available: available
          }
        )
        (ok true)
      )
    )
  )
)

(define-public (match-products-for-user (user-id principal) (product-ids (list 50 uint)))
  (begin
    (map-set product-matches
      { user-id: user-id }
      { matched-products: product-ids }
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)

(define-read-only (get-matched-products (user-id principal))
  (default-to { matched-products: (list) } (map-get? product-matches { user-id: user-id }))
)

(define-read-only (is-product-match (user-id principal) (product-id uint))
  (let ((matches (get matched-products (get-matched-products user-id))))
    (is-some (index-of matches product-id))
  )
)
