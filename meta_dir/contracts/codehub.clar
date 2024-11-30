;; Digital Art Authentication and Licensing System
;; Description: Smart contract system for authenticating and managing digital artwork licenses on Stacks blockchain

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_INPUT (err u101))
(define-constant ERR_NOT_FOUND (err u102))
(define-constant ERR_ALREADY_EXISTS (err u103))
(define-constant ERR_INVALID_STATUS (err u104))

;; Status constants with explicit type casting
(define-constant LICENSE_VALID "valid")
(define-constant LICENSE_REVOKED "revoked")
(define-constant LICENSE_EXPIRED "expired")

;; Data Variables
(define-data-var license-counter uint u0)

;; Data Maps
(define-map artworks 
    {token-id: (string-ascii 50)}
    {
        artist: (string-ascii 50),
        collection: (string-ascii 50),
        creator: principal,
        timestamp: uint,
        status: (string-ascii 20),
        current-licensee: principal
    }
)

(define-map creators principal bool)
(define-map galleries principal bool)

;; Artwork license history tracking
(define-map license-history
    {token-id: (string-ascii 50), index: uint}
    {
        licensee: principal,
        timestamp: uint,
        action: (string-ascii 20)
    }
)

;; Track history indices
(define-map history-indices
    (string-ascii 50) ;; token-id
    uint              ;; current index
)

;; Read-only functions
(define-read-only (get-artwork (token-id (string-ascii 50)))
    (map-get? artworks {token-id: token-id})
)

(define-read-only (is-creator (address principal))
    (default-to false (map-get? creators address))
)

(define-read-only (is-gallery (address principal))
    (default-to false (map-get? galleries address))
)

(define-read-only (get-current-timestamp)
    (var-get license-counter)
)

;; Administrative functions
(define-public (register-creator (creator principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (map-get? creators creator)) ERR_ALREADY_EXISTS)
        (ok (map-set creators creator true))
    )
)

(define-public (register-gallery (gallery principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (map-get? galleries gallery)) ERR_ALREADY_EXISTS)
        (ok (map-set galleries gallery true))
    )
)

;; Artwork registration
(define-public (mint-artwork 
    (token-id (string-ascii 50))
    (artist (string-ascii 50))
    (collection (string-ascii 50)))
    
    (let
        (
            (creator tx-sender)
            (timestamp (var-get license-counter))
        )
        
        ;; Verify creator authorization
        (asserts! (is-creator creator) ERR_NOT_AUTHORIZED)
        
        ;; Check artwork doesn't already exist
        (asserts! (is-none (get-artwork token-id)) ERR_ALREADY_EXISTS)
        
        ;; Validate input
        (asserts! (> (len artist) u0) ERR_INVALID_INPUT)
        (asserts! (> (len collection) u0) ERR_INVALID_INPUT)
        
        ;; Register artwork
        (map-set artworks
            {token-id: token-id}
            {
                artist: artist,
                collection: collection,
                creator: creator,
                timestamp: timestamp,
                status: LICENSE_VALID,
                current-licensee: creator
            }
        )
        
        ;; Initialize history
        (map-set license-history
            {token-id: token-id, index: u0}
            {
                licensee: creator,
                timestamp: timestamp,
                action: "minted"
            }
        )
        (map-set history-indices token-id u1)
        
        ;; Increment license counter
        (var-set license-counter (+ timestamp u1))
        
        (ok true)
    )
)

;; Transfer license
(define-public (transfer-license
    (token-id (string-ascii 50))
    (new-licensee principal))
    
    (let
        (
            (artwork (unwrap! (get-artwork token-id) ERR_NOT_FOUND))
            (timestamp (var-get license-counter))
            (current-index (default-to u0 (map-get? history-indices token-id)))
        )
        
        ;; Verify sender owns the license
        (asserts! (is-eq (get current-licensee artwork) tx-sender) ERR_NOT_AUTHORIZED)
        
        ;; Validate new licensee
        (asserts! (or (is-creator new-licensee) (is-gallery new-licensee)) ERR_INVALID_INPUT)
        
        ;; Update artwork license
        (map-set artworks
            {token-id: token-id}
            (merge artwork {current-licensee: new-licensee})
        )
        
        ;; Record transfer in history
        (map-set license-history
            {token-id: token-id, index: current-index}
            {
                licensee: new-licensee,
                timestamp: timestamp,
                action: "transferred"
            }
        )
        (map-set history-indices token-id (+ current-index u1))
        
        ;; Increment license counter
        (var-set license-counter (+ timestamp u1))
        
        (ok true)
    )
)

;; Verify artwork authenticity
(define-public (verify-artwork
    (token-id (string-ascii 50)))
    
    (let
        (
            (artwork (unwrap! (get-artwork token-id) ERR_NOT_FOUND))
        )
        
        ;; Verify creator is still authorized
        (asserts! (is-creator (get creator artwork)) ERR_NOT_AUTHORIZED)
        
        ;; Return verification result
        (ok {
            is-authentic: true,
            creator: (get creator artwork),
            current-licensee: (get current-licensee artwork),
            status: (get status artwork)
        })
    )
)

;; Get license history
(define-read-only (get-license-history 
    (token-id (string-ascii 50))
    (index uint))
    
    (map-get? license-history {token-id: token-id, index: index})
)

;; Update license status
(define-public (update-license-status
    (token-id (string-ascii 50))
    (new-status (string-ascii 20)))
    
    (let
        (
            (artwork (unwrap! (get-artwork token-id) ERR_NOT_FOUND))
        )
        
        ;; Only creator can update status
        (asserts! (is-eq (get creator artwork) tx-sender) ERR_NOT_AUTHORIZED)
        
        ;; Validate status
        (asserts! (or
            (is-eq new-status LICENSE_VALID)
            (is-eq new-status LICENSE_REVOKED)
            (is-eq new-status LICENSE_EXPIRED)
        ) ERR_INVALID_STATUS)
        
        ;; Update status
        (ok (map-set artworks
            {token-id: token-id}
            (merge artwork {status: new-status})
        ))
    )
)