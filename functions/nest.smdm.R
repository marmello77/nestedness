nest.smdm =function(x,constrains=NULL, weights=F, decreasing="fill", sort=T){
  ### Checking inputs ####
  if (!is.null(constrains)&length(unique(constrains))==1){
    warning("Only one module. Nestedness calculated only for the entire matrix")
    constrains=NULL}
  if(is.element(NA,constrains)|is.element(NaN,constrains)){
    warning("NA or NaN in constrains. Nestedness calculated only for the entire matrix")
    constrains=NULL
  }
  if (!is.null(constrains)&length(constrains)!=nrow(x)+ncol(x)){
    stop("constrains vector is not of the same length that network vertices")
  }
  if (weights==F&any(x!=0&x!=1)){
    x[x>0]=1
    warning ("binary metric applied")
  }
  if (decreasing!="fill"&decreasing!="abund"){
    stop("decreasing should be fill or abund")
  }
  if (!is.null(constrains)){constrains=as.character(constrains)}
  if(is.null(rownames(x))){
    xrnames=paste("R",1:nrow(x),"")
    rownames(x)<-xrnames
  }
  if(is.null(colnames(x))){
    xcnames=paste("C",1:ncol(x),"")
    colnames(x)<-xcnames
  }
  ### Unweighted NODF Function ####
  unweightednodf=function (x,constrains){
    # Sorting matrix order by row and collumn sums
    if (sort==T){tab0=x[sort(rowSums(x), index=T, decreasing=TRUE)$ix,
                        sort(colSums(x), index=T, decreasing=TRUE)$ix]}
    else {tab0=x}
    
    # N for rows
    MTrow= rowSums(tab0)
    Nrow= matrix(rep(NA,times=nrow(tab0)^2),nrow(tab0),nrow(tab0))
    dimnames(Nrow)=list(rownames(tab0),rownames(tab0))
    
    for (jrow in 2:nrow(tab0)){
      for (irow in 1:(jrow-1)){
        if (MTrow[jrow]>=MTrow[irow]){Nrow[jrow,irow]=0} 
        else {
          S=0
          for(i in 1:ncol(tab0)){
            if (tab0[jrow,i]==1&tab0[jrow,i]==tab0[irow,i]) {
              S=S+1
            }
          }
          Nrow[jrow,irow]=S*100/MTrow[jrow]
        }
      }
      
    }      
    Nrow=Nrow[rownames(x), rownames(x)]
    
    # NODF for rows
    NODFrow= mean(Nrow,na.rm = T)
    
    # N for collumns
    
    MTcol= colSums(tab0)
    Ncol= matrix(rep(NA,times=ncol(tab0)^2),ncol(tab0),ncol(tab0))
    dimnames(Ncol)=list(colnames(tab0),colnames(tab0))
    
    for (jcol in 2:ncol(tab0)){
      for (icol in 1:(jcol-1)){
        if (MTcol[jcol]>=MTcol[icol]){Ncol[jcol,icol]=0} 
        else {
          S=0
          for(i in 1:nrow(tab0)){
            if (tab0[i,jcol]==1&tab0[i,jcol]==tab0[i,icol]) {
              S=S+1
            }
          }
          Ncol[jcol,icol]=S*100/MTcol[jcol]
        }
      }
      
    }      
    Ncol=Ncol[colnames(x),colnames(x)]
    
    # NODF for rows
    NODFcol= mean(Ncol,na.rm = T)
    
    # NODF for the entire matrix
    NODFmatrix= mean(c(Ncol,Nrow),na.rm=T)
    
    #### NODF SM/DM ###
    if (!is.null(constrains)){
      # Constrains for rows
      
      rowcons=cbind (rownames(x),constrains[1:nrow(x)])
      tabrcons=table(rowcons[,1],rowcons[,2])
      distrcons= dist(tabrcons,method = "binary")
      distrcons= as.matrix (distrcons)
      distrcons=distrcons[rownames(x),rownames(x)]
      rm(rowcons,tabrcons)
      
      # NODF SM/DM for rows
      SM_Nrow=0
      SM_nrow=0
      DM_Nrow=0
      DM_nrow=0
      for (i in 1:nrow(x)){
        for (j in 1:nrow(x)){
          if (!is.na(Nrow[i,j])){
            if(distrcons[i,j]==0){
              SM_Nrow=SM_Nrow+Nrow[i,j]
              SM_nrow=SM_nrow+1
            }
            else{
              DM_Nrow=DM_Nrow+Nrow[i,j]
              DM_nrow=DM_nrow+1
            }
          }
        }
      }
      NODF_SM_row= SM_Nrow/SM_nrow
      NODF_DM_row= DM_Nrow/DM_nrow
      
      # Constrains for collumns
      
      colcons=cbind (colnames(x),constrains[(nrow(x)+1):length(constrains)])
      tabccons=table(colcons[,1],colcons[,2])
      distccons= dist(tabccons,method = "binary")
      distccons= as.matrix (distccons)
      distccons=distccons[colnames(x),colnames(x)]
      rm(colcons,tabccons)
      
      # NODF SM/DM for collumns
      SM_Ncol=0
      SM_ncol=0
      DM_Ncol=0
      DM_ncol=0
      for (i in 1:ncol(x)){
        for (j in 1:ncol(x)){
          if (!is.na(Ncol[i,j])){
            if(distccons[i,j]==0){
              SM_Ncol=SM_Ncol+Ncol[i,j]
              SM_ncol=SM_ncol+1
            }
            else{
              DM_Ncol=DM_Ncol+Ncol[i,j]
              DM_ncol=DM_ncol+1
            }
          }
        }
      }
      NODF_SM_col= SM_Ncol/SM_ncol
      NODF_DM_col= DM_Ncol/DM_ncol
      
      # NODF SM/DM for matrix
      
      NODF_SM_matrix= (SM_Nrow+SM_Ncol)/(SM_nrow+SM_ncol)
      NODF_DM_matrix= (DM_Nrow+DM_Ncol)/(DM_nrow+DM_ncol)
      # return
      return(list(NODFrow=NODFrow,NODFcol=NODFcol, NODFmatrix=NODFmatrix,
                  NODF_SM_row= NODF_SM_row, NODF_DM_row=NODF_DM_row, 
                  NODF_SM_col= NODF_SM_col, NODF_DM_col=NODF_DM_col,
                  NODF_SM_matrix= NODF_SM_matrix, NODF_DM_matrix=NODF_DM_matrix))
      
    }
    else {
      return(list(NODFrow=NODFrow,NODFcol=NODFcol, NODFmatrix=NODFmatrix))}
  }
  ### Weighted NODF function ####
  weightednodf=function (x,constrains){
    # Sorting matrix order by row and collumn sums
    if(sort==T){tab0=x[sort(rowSums(x!=0), index=T, decreasing=TRUE)$ix,
                       sort(colSums(x!=0), index=T, decreasing=TRUE)$ix]}
    else{tab0=x}
    
    # N for rows
    MTrow= rowSums(tab0)
    Frow= rowSums(tab0!=0)
    Nrow= matrix(rep(NA,times=nrow(tab0)^2),nrow(tab0),nrow(tab0))
    dimnames(Nrow)=list(rownames(tab0),rownames(tab0))
    
    for (jrow in 2:nrow(tab0)){
      for (irow in 1:(jrow-1)){
        if (Frow[jrow]>=Frow[irow]){Nrow[jrow,irow]=0} 
        else {
          S=0
          for(i in 1:ncol(tab0)){
            if (tab0[jrow,i]!=0&tab0[jrow,i]<tab0[irow,i]) {
              S=S+1
            }
          }
          Nrow[jrow,irow]=S*100/Frow[jrow]
        }
      }
      
    }      
    Nrow=Nrow[rownames(x), rownames(x)]
    
    # WNODF for rows
    NODFrow= mean(Nrow,na.rm = T)
    
    # N for collumns
    
    MTcol= colSums(tab0)
    Fcol= colSums(tab0!=0)
    Ncol= matrix(rep(NA,times=ncol(tab0)^2),ncol(tab0),ncol(tab0))
    dimnames(Ncol)=list(colnames(tab0),colnames(tab0))
    
    for (jcol in 2:ncol(tab0)){
      for (icol in 1:(jcol-1)){
        if (Fcol[jcol]>=Fcol[icol]){Ncol[jcol,icol]=0}
        else {
          S=0
          for(i in 1:nrow(tab0)){
            if (tab0[i,jcol]!=0&tab0[i,jcol]<tab0[i,icol]) {
              S=S+1
            }
          }
          Ncol[jcol,icol]=S*100/Fcol[jcol]
        }
      }
      
    }      
    Ncol=Ncol[colnames(x),colnames(x)]
    
    # WNODF for rows
    NODFcol= mean(Ncol,na.rm = T)
    
    # WNODF for the entire matrix
    NODFmatrix= mean(c(Ncol,Nrow),na.rm=T)
    
    #### WNODF SM/DM ###
    if (!is.null(constrains)){
      # Constrains for rows
      
      rowcons=cbind (rownames(x),constrains[1:nrow(x)])
      tabrcons=table(rowcons[,1],rowcons[,2])
      distrcons= dist(tabrcons,method = "binary")
      distrcons= as.matrix (distrcons)
      distrcons=distrcons[rownames(x),rownames(x)]
      rm(rowcons,tabrcons)
      
      # WNODF SM/DM for rows
      SM_Nrow=0
      SM_nrow=0
      DM_Nrow=0
      DM_nrow=0
      for (i in 1:nrow(x)){
        for (j in 1:nrow(x)){
          if (!is.na(Nrow[i,j])){
            if(distrcons[i,j]==0){
              SM_Nrow=SM_Nrow+Nrow[i,j]
              SM_nrow=SM_nrow+1
            }
            else{
              DM_Nrow=DM_Nrow+Nrow[i,j]
              DM_nrow=DM_nrow+1
            }
          }
        }
      }
      NODF_SM_row= SM_Nrow/SM_nrow
      NODF_DM_row= DM_Nrow/DM_nrow
      
      # Constrains for collumns
      
      colcons=cbind (colnames(x),constrains[(nrow(x)+1):length(constrains)])
      tabccons=table(colcons[,1],colcons[,2])
      distccons= dist(tabccons,method = "binary")
      distccons= as.matrix (distccons)
      distccons=distccons[colnames(x),colnames(x)]
      rm(colcons,tabccons)
      
      # WNODF SM/DM for collumns
      SM_Ncol=0
      SM_ncol=0
      DM_Ncol=0
      DM_ncol=0
      for (i in 1:ncol(x)){
        for (j in 1:ncol(x)){
          if (!is.na(Ncol[i,j])){
            if(distccons[i,j]==0){
              SM_Ncol=SM_Ncol+Ncol[i,j]
              SM_ncol=SM_ncol+1
            }
            else{
              DM_Ncol=DM_Ncol+Ncol[i,j]
              DM_ncol=DM_ncol+1
            }
          }
        }
      }
      NODF_SM_col= SM_Ncol/SM_ncol
      NODF_DM_col= DM_Ncol/DM_ncol
      
      # WNODF SM/DM for matrix
      NODF_SM_matrix= (SM_Nrow+SM_Ncol)/(SM_nrow+SM_ncol)
      NODF_DM_matrix= (DM_Nrow+DM_Ncol)/(DM_nrow+DM_ncol)
      # return
      return(list(WNODFrow=NODFrow,WNODFcol=NODFcol, WNODFmatrix=NODFmatrix,WNODF_SM_row= NODF_SM_row, WNODF_DM_row=NODF_DM_row,WNODF_SM_col= NODF_SM_col, WNODF_DM_col=NODF_DM_col,WNODF_SM_matrix= NODF_SM_matrix, WNODF_DM_matrix=NODF_DM_matrix))
      
    }
    else {
      return(list(WNODFrow=NODFrow,WNODFcol=NODFcol, WNODFmatrix=NODFmatrix))}
  }
  ### Weighted NODA funcion ####
  weightednoda=function (x,constrains){
    # Sorting matrix order by row and collumn sums
    if(sort==T){tab0=x[sort(rowSums(x), index=T, decreasing=TRUE)$ix,
                       sort(colSums(x), index=T, decreasing=TRUE)$ix]}
    else{tab0=x}
    
    # N for rows
    MTrow= rowSums(tab0)
    Frow= rowSums(tab0!=0)
    Nrow= matrix(rep(NA,times=nrow(tab0)^2),nrow(tab0),nrow(tab0))
    dimnames(Nrow)=list(rownames(tab0),rownames(tab0))
    
    for (jrow in 2:nrow(tab0)){
      for (irow in 1:(jrow-1)){
        if (MTrow[jrow]>=MTrow[irow]){Nrow[jrow,irow]=0}
        else {
          S=0
          for(i in 1:ncol(tab0)){
            if (tab0[jrow,i]!=0&tab0[jrow,i]<tab0[irow,i]) {
              S=S+1
            }
          }
          Nrow[jrow,irow]=S*100/Frow[jrow]
        }
      }
      
    }      
    Nrow=Nrow[rownames(x), rownames(x)]
    
    # WNODA for rows
    NODArow= mean(Nrow,na.rm = T)
    
    # N for collumns
    
    MTcol= colSums(tab0)
    Fcol= colSums(tab0!=0)
    Ncol= matrix(rep(NA,times=ncol(tab0)^2),ncol(tab0),ncol(tab0))
    dimnames(Ncol)=list(colnames(tab0),colnames(tab0))
    
    for (jcol in 2:ncol(tab0)){
      for (icol in 1:(jcol-1)){
        if (MTcol[jcol]>=MTcol[icol]){Ncol[jcol,icol]=0}
        else {
          S=0
          for(i in 1:nrow(tab0)){
            if (tab0[i,jcol]!=0&tab0[i,jcol]<tab0[i,icol]) {
              S=S+1
            }
          }
          Ncol[jcol,icol]=S*100/Fcol[jcol]
        }
      }
      
    }      
    Ncol=Ncol[colnames(x),colnames(x)]
    
    # NODA for rows
    NODAcol= mean(Ncol,na.rm = T)
    
    # NODA for the entire matrix
    NODAmatrix= mean(c(Ncol,Nrow),na.rm=T)
    
    #### WNODA SM/DM ###
    if (!is.null(constrains)){
      
      # Constrains for rows
      rowcons=cbind (rownames(x),constrains[1:nrow(x)])
      tabrcons=table(rowcons[,1],rowcons[,2])
      distrcons= dist(tabrcons,method = "binary")
      distrcons= as.matrix (distrcons)
      distrcons=distrcons[rownames(x),rownames(x)]
      rm(rowcons,tabrcons)
      
      # WNODA SM/DM for rows
      SM_Nrow=0
      SM_nrow=0
      DM_Nrow=0
      DM_nrow=0
      for (i in 1:nrow(x)){
        for (j in 1:nrow(x)){
          if (!is.na(Nrow[i,j])){
            if(distrcons[i,j]==0){
              SM_Nrow=SM_Nrow+Nrow[i,j]
              SM_nrow=SM_nrow+1
            }
            else{
              DM_Nrow=DM_Nrow+Nrow[i,j]
              DM_nrow=DM_nrow+1
            }
          }
        }
      }
      NODA_SM_row= SM_Nrow/SM_nrow
      NODA_DM_row= DM_Nrow/DM_nrow
      
      # Constrains for collumns
      
      colcons=cbind (colnames(x),constrains[(nrow(x)+1):length(constrains)])
      tabccons=table(colcons[,1],colcons[,2])
      distccons= dist(tabccons,method = "binary")
      distccons= as.matrix (distccons)
      distccons=distccons[colnames(x),colnames(x)]
      rm(colcons,tabccons)
      
      # WNODA SM/DM for collumns
      SM_Ncol=0
      SM_ncol=0
      DM_Ncol=0
      DM_ncol=0
      for (i in 1:ncol(x)){
        for (j in 1:ncol(x)){
          if (!is.na(Ncol[i,j])){
            if(distccons[i,j]==0){
              SM_Ncol=SM_Ncol+Ncol[i,j]
              SM_ncol=SM_ncol+1
            }
            else{
              DM_Ncol=DM_Ncol+Ncol[i,j]
              DM_ncol=DM_ncol+1
            }
          }
        }
      }
      NODA_SM_col= SM_Ncol/SM_ncol
      NODA_DM_col= DM_Ncol/DM_ncol
      
      # WNODA SM/DM for matrix
      
      NODA_SM_matrix= (SM_Nrow+SM_Ncol)/(SM_nrow+SM_ncol)
      NODA_DM_matrix= (DM_Nrow+DM_Ncol)/(DM_nrow+DM_ncol)
      # return
      return(list(WNODArow=NODArow,WNODAcol=NODAcol, WNODAmatrix=NODAmatrix,
                  WNODA_SM_row= NODA_SM_row, WNODA_DM_row=NODA_DM_row, 
                  WNODA_SM_col= NODA_SM_col, WNODA_DM_col=NODA_DM_col,
                  WNODA_SM_matrix= NODA_SM_matrix, WNODA_DM_matrix=NODA_DM_matrix))
      
    }
    else {
      return(list(WNODArow=NODArow,WNODAcol=NODAcol, WNODAmatrix=NODAmatrix))}
  }
  
  ### Using functions ####
  if(decreasing=="abund"){
    return(weightednoda(x,constrains))
  }
  if (decreasing=="fill"){
    if (weights==F){
      return(unweightednodf(x,constrains))
    }
    if (weights==T){
      return(weightednodf(x,constrains))
    }
  }
}