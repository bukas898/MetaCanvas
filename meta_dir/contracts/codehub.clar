;; METACANVA: License Transfer

;; Extending Stage 1
(define-map licenses 
  { token-id: (buff 32) } 
  { owner: principal })

;; Function to transfer license
(define-public (transfer-license (token-id (buff 32)) (new-owner principal))
  (let 
    ((license (map-get licenses { token-id: token-id })))
    (if (is-none license)
        (err u102) ;; ERR_NOT_FOUND
        (if (is-eq (get owner (unwrap license u102)) tx-sender)
            (begin
              (map-set licenses { token-id: token-id } { owner: new-owner })
              (ok token-id)
            )
            (err ERR_NOT_AUTHORIZED)
        )
    )
  )
)

;; Update mint-artwork to initialize license owner
(define-public (mint-artwork (token-id (buff 32)) (artist principal) (collection (buff 64)))
  (if (not (contains? creators tx-sender))
      (err ERR_NOT_AUTHORIZED)
      (if (map-get artworks { token-id: token-id })
          (err ERR_ALREADY_EXISTS)
          (begin
            (map-set artworks 
              { token-id: token-id } 
              { artist: artist, collection: collection, timestamp: (block-height) })
            (map-set licenses { token-id: token-id } { owner: artist })
            (ok token-id)
          )
      )
  )
)
