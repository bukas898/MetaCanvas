;; METACANVAS: Basic Artwork Registration
;; Author: Amobi Ndubuisi

;; Data map to store artwork details
(define-map artworks 
  { token-id: (buff 32) } 
  { artist: principal, collection: (buff 64), timestamp: uint })

;; Authorized creators
(define-set creators (principal))

;; Constants for errors
(define-constant ERR_NOT_AUTHORIZED u100)
(define-constant ERR_ALREADY_EXISTS u103)

;; Function to register a creator
(define-public (register-creator (creator principal))
  (begin
    (set (creators creator))
    (ok creator)
  )
)

;; Function to mint artwork
(define-public (mint-artwork (token-id (buff 32)) (artist principal) (collection (buff 64)))
  (if (not (contains? creators tx-sender))
      (err ERR_NOT_AUTHORIZED)
      (if (map-get artworks { token-id: token-id })
          (err ERR_ALREADY_EXISTS)
          (begin
            (map-set artworks 
              { token-id: token-id } 
              { artist: artist, collection: collection, timestamp: (block-height) })
            (ok token-id)
          )
      )
  )
)
