# Note that if you are on osx running anaconda as of 31-Aug-2015 rPython has a problem linking with it
# try normal python with sklearn and pandas installed manually
modelInfo <- list(label = "Knn regression via sklearn.neighbors.KNeighborsRegressor",
                  library = "rPython",
                  loop = NULL,
                  type = "Regression",
                  parameters = data.frame(parameter = c('n_neighbors','weights','algorithm','leaf_size','metric','p'),
                                          class = c("numeric", "character", "character", "numeric", "character", "numeric"),
                                          label = c("#Neighbors", 'Weight Function','Algorithm', 'Leaf Size', 'Distance Metric','p')),
                  grid = function(x, y, len = NULL, search = "grid") {
                    if(search == "grid") {
                      out <- expand.grid(n_neighbors=(5:((2 * len)+4))[(5:((2 * len)+4))%%2 > 0],
                                         weights = c("uniform", "distance"),
                                         algorithm = c('auto'),
                                         leaf_size = c(30), 
                                         metric = c("minkowski"),
                                         p=2)
                    } else {
                      out <- data.frame(n_neighbors = sample(1:floor(nrow(x)/3), size = len, replace = TRUE),
                                        weights = sample(c("uniform", "distance"), size = len, replace = TRUE),
                                        algorithm = c('auto'),
                                        leaf_size = c(30), 
                                        metric = c("minkowski"),
                                        p  = sample(1:2, size = len, replace = TRUE))
                    }
                    out
                  },
                  fit = function(x, y, wts, param, lev, last, classProbs, ...) {
                    if(!is.data.frame(x)) x <- as.data.frame(x)
                    mySeed=sample.int(100000, 1)
                    python.exec('import numpy as np')
                    python.assign('mySeed',mySeed)
                    python.exec('np.random.seed(mySeed)')
                    
                    python.assign('X',x);python.exec('X = pd.DataFrame(X)')
                    python.assign('Y',y)
                    python.exec(paste0('neigh = KNeighborsRegressor(',
                                       'n_neighbors=',param$n_neighbors,',',
                                       'weights=\'',as.character(param$weights),'\',',
                                       'algorithm=\'',as.character(param$algorithm),'\',',
                                       'leaf_size=',param$leaf_size,',',
                                       'metric=\'',as.character(param$metric),'\',',
                                       'p=',param$p,
                                       ')'))
                    python.exec('neigh.fit(X, Y)')
                    return (list())
                  },
                  predict = function(modelFit, newdata, submodels = NULL) {
                    if(!is.data.frame(newdata)) newdata <- as.data.frame(newdata)
                    python.assign('newdata',newdata);python.exec('newdata = pd.DataFrame(newdata)')
                    python.exec('pred=neigh.predict(newdata)')
                    python.exec("pred = pred.tolist()")  
                    pred=python.get("pred")                                        
                  },
                  levels = function(x) x$obsLevels,
                  tags = "Prototype Models",
                  prob = NULL,
                  sort = function(x) x[order(-x[,1]),]
)
