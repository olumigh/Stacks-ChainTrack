;; Stacks-ChaainTrack - Supply Chain Tracking Smart Contract
;; Tracks products through their lifecycle in the supply chain

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-status (err u103))

;; Data Maps
(define-map products
    { product-id: (string-ascii 36) }
    {
        manufacturer: principal,
        current-owner: principal,
        name: (string-ascii 64),
        status: (string-ascii 20),
        timestamp: uint,
        location: (string-ascii 100)
    }
)

(define-map product-history
    { product-id: (string-ascii 36), index: uint }
    {
        owner: principal,
        status: (string-ascii 20),
        timestamp: uint,
        location: (string-ascii 100),
        notes: (string-ascii 200)
    }
)

(define-map history-indices
    { product-id: (string-ascii 36) }
    { current-index: uint }
)

;; Private Functions
(define-private (is-owner)
    (is-eq tx-sender contract-owner)
)

(define-private (get-current-index (product-id (string-ascii 36)))
    (default-to u0 (get current-index (map-get? history-indices { product-id: product-id })))
)

(define-private (increment-history-index (product-id (string-ascii 36)))
    (let ((current-idx (get-current-index product-id)))
        (map-set history-indices
            { product-id: product-id }
            { current-index: (+ current-idx u1) }
        )
        (+ current-idx u1)
    )
)

;; Public Functions
(define-public (register-product 
    (product-id (string-ascii 36))
    (name (string-ascii 64))
    (location (string-ascii 100)))
    (begin
        (asserts! (is-owner) err-owner-only)
        (map-set products
            { product-id: product-id }
            {
                manufacturer: tx-sender,
                current-owner: tx-sender,
                name: name,
                status: "manufactured",
                timestamp: block-height,
                location: location
            }
        )
        ;; Initialize history
        (map-set product-history
            { product-id: product-id, index: u0 }
            {
                owner: tx-sender,
                status: "manufactured",
                timestamp: block-height,
                location: location,
                notes: "Product registered"
            }
        )
        (map-set history-indices
            { product-id: product-id }
            { current-index: u1 }
        )
        (ok true)
    )
)

(define-public (transfer-ownership
    (product-id (string-ascii 36))
    (new-owner principal)
    (location (string-ascii 100))
    (notes (string-ascii 200)))
    (let (
        (product (unwrap! (map-get? products { product-id: product-id }) err-not-found))
        (current-owner (get current-owner product))
    )
        (asserts! (is-eq tx-sender current-owner) err-unauthorized)
        ;; Update product current state
        (map-set products
            { product-id: product-id }
            (merge product {
                current-owner: new-owner,
                timestamp: block-height,
                location: location
            })
        )
        ;; Add to history
        (map-set product-history
            { product-id: product-id, index: (increment-history-index product-id) }
            {
                owner: new-owner,
                status: (get status product),
                timestamp: block-height,
                location: location,
                notes: notes
            }
        )
        (ok true)
    )
)

(define-public (update-status
    (product-id (string-ascii 36))
    (new-status (string-ascii 20))
    (location (string-ascii 100))
    (notes (string-ascii 200)))
    (let (
        (product (unwrap! (map-get? products { product-id: product-id }) err-not-found))
        (current-owner (get current-owner product))
    )
        (asserts! (is-eq tx-sender current-owner) err-unauthorized)
        ;; Update product current state
        (map-set products
            { product-id: product-id }
            (merge product {
                status: new-status,
                timestamp: block-height,
                location: location
            })
        )
        ;; Add to history
        (map-set product-history
            { product-id: product-id, index: (increment-history-index product-id) }
            {
                owner: current-owner,
                status: new-status,
                timestamp: block-height,
                location: location,
                notes: notes
            }
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-product-details (product-id (string-ascii 36)))
    (map-get? products { product-id: product-id })
)

(define-read-only (get-history-entry 
    (product-id (string-ascii 36))
    (index uint))
    (map-get? product-history { product-id: product-id, index: index })
)

(define-read-only (get-history-length (product-id (string-ascii 36)))
    (get-current-index product-id)
)