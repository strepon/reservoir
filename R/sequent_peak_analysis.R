#' @title Rippl analysis
#' @description Computes the Rippl no-failure storage for a given time series of inflows and target release using the sequent peak algorith. Returns storage behavior time-series. 
#' @param Q             a time series or vector  of net inflows to the reservoir.
#' @param R             a time series or vector of target releases. Must be the same length as Q.
#' @param double_cycle  logical. If TRUE the input series will be replicated and placed end-to-end to double the simulation. (Recommended if the critical period occurs at the end of the recorded inflow time series)
#' @param plot          logical. If TRUE (the default) the storage behavior diagram is plotted.
#' @return Returns the storage behaviour time series for the no-failure (Rippl) reservoir given net inflows Q and target release R.
#' @references Rippl, W. (1883) The capacity of storage reservoirs for water supply, In Proceedings of the Institute of Civil Engineers, 71, 270-278.
#' @references Thomas H.A., Burden R.P. (1963) Operations research in water quality management. Harvard Water Resources Group, Cambridge
#' @references Loucks, D.P., van Beek, E., Stedinger, J.R., Dijkman, J.P.M. and Villars, M.T. (2005) Water resources systems planning and management: An introduction to methods, models and applications. Unesco publishing, Paris, France.
#' @examples # define a release vector for a constant release equal to 70 % of the mean inflow
#' release <- rep(mean(HollandCreek.ts) * 0.7, length(HollandCreek.ts))
#' no_fail_storage <- Rippl(HollandCreek.ts,release)
#' @export
Rippl <- function(Q, R, double_cycle = FALSE, plot = TRUE) {
    if (length(Q) != length(R))
        stop("Q and R must be of equal length")
    if (is.ts(Q) == FALSE && is.vector(Q) == FALSE)
        stop("Q must be time series or vector object")
    if (is.ts(R) == FALSE && is.vector(R) == FALSE)
        stop("R must be time series or vector object")
    if (double_cycle) {
        Q <- ts(c(Q, Q), start = start(Q), frequency = frequency(Q))
        R <- c(R, R)
    }
    K <- vector("numeric", length = length(Q) + 1)
    for (t in 1:length(Q)) {
        if (R[t] - Q[t] + K[t] > 0) {
            K[t + 1] <- R[t] - Q[t] + K[t]
        } else {
            K[t + 1] <- 0
        }
    }
    K <- ts(K[2:length(K)], start = start(Q), frequency = frequency(Q))
    if (plot) {
        layout(1:2)
        plot(Q, ylab = "inflow", type = "l")
        plot(max(K) - K, ylab = "storage")
    }
    results <- list(max(K),(max(K) - K))
    names(results) <- c("Rippl_storage","Storage_behavior")
    return(results)
}