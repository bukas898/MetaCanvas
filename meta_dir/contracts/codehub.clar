;; METACANVA: License Status Management and Verification

;; Extending Stage 2
(define-map license-status 
  { token-id: (buff 32) } 
  { status: (buff 16) })

;; Function to update license status
(define-public (update-license-status (token-id (buff 32)) (status (buff 16)))
  (let 
    ((license (map-get licenses { token-id: token-id })))
    (if (is-none license)
        (err u102) ;; ERR_NOT_FOUND
        (if (is-eq (get owner (unwrap license u102)) tx-sender)
            (begin
              (map-set license-status { token-id: token-id } { status: status })
              (ok token-id)
            )
            (err ERR_NOT_AUTHORIZED)
        )
    )
  )
)

;; Function to verify artwork
(define-read-only (verify-artwork (token-id (buff 32)))
  (match (map-get artworks { token-id: token-id })
    artwork (ok { artist: (get artist artwork), collection: (get collection artwork) })
    (err u102) ;; ERR_NOT_FOUND
  )
)
