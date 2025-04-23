;; Manufacturer Verification Contract
;; Validates legitimate medical suppliers in the healthcare supply chain

(define-data-var admin principal tx-sender)

;; Data map to store manufacturer information
(define-map manufacturers
  { manufacturer-id: (string-ascii 20) }
  {
    name: (string-ascii 50),
    address: (string-ascii 100),
    license-number: (string-ascii 30),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a new manufacturer (only admin)
(define-public (register-manufacturer
    (manufacturer-id (string-ascii 20))
    (name (string-ascii 50))
    (address (string-ascii 100))
    (license-number (string-ascii 30)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? manufacturers { manufacturer-id: manufacturer-id })) (err u100))
    (ok (map-set manufacturers
      { manufacturer-id: manufacturer-id }
      {
        name: name,
        address: address,
        license-number: license-number,
        verified: false,
        verification-date: u0
      }
    ))
  )
)

;; Public function to verify a manufacturer (only admin)
(define-public (verify-manufacturer (manufacturer-id (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? manufacturers { manufacturer-id: manufacturer-id })
      manufacturer (ok (map-set manufacturers
                        { manufacturer-id: manufacturer-id }
                        (merge manufacturer {
                          verified: true,
                          verification-date: block-height
                        })
                      ))
      (err u404)
    )
  )
)

;; Public function to check if a manufacturer is verified
(define-read-only (is-manufacturer-verified (manufacturer-id (string-ascii 20)))
  (match (map-get? manufacturers { manufacturer-id: manufacturer-id })
    manufacturer (ok (get verified manufacturer))
    (err u404)
  )
)

;; Public function to get manufacturer details
(define-read-only (get-manufacturer-details (manufacturer-id (string-ascii 20)))
  (map-get? manufacturers { manufacturer-id: manufacturer-id })
)

;; Function to transfer admin rights (only current admin)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
