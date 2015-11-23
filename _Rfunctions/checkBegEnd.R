checkBegEnd = function(data) {
  
  # CHECK NUMBER OF BEG AND END COUNTS FOR EACH TRANSECT
  begc = subset(data, type == "BEGCNT", select = c(count))
  endc = subset(data, type == "ENDCNT", select = c(count))
  
  if (nrow(begc) != nrow(endc)) {
    f = as.data.frame(matrix(ncol = 4))
    a = unique(data$transect)
    
    for (b in 1:end(a)[1]) {
      f = rbind(f, cbind(a[b], sum(data$count == a[b] & data$type == "BEGCNT"), 
                         sum(data$count == a[b] & data$type == "ENDCNT"), 
                         data$obs[data$count == a[b]][1]))
    }
    
    g = f[which(f[,2] != f[,3]),]
    g = g[order(g[1]),]
    colnames(g) = c("Transects", "BegFreq", "EndFreq", "Observer")
    
    message("Found ", nrow(g) ," error(s) in Beg and End count rows")
    
    write.csv(g, file.path(dir.out, "BegEndErrors.csv"), row.names = FALSE)
  } else message("Found ", 0 ," errors in Beg and End count rows")
  
}
