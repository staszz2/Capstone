fileBIN <- "C:\\Users\\zveres\\Documents\\GitHub\\Capstone\\news_text.txt"
fileTXT <- "C:\\Users\\zveres\\Documents\\GitHub\\Capstone\\comments_clean.txt"

reconvert <- FALSE
if(reconvert)
{
rtcwbin = readBin(fileBIN, raw(), file.info(fileBIN)$size)
rtcwbin[rtcwbin==as.raw(0) | rtcwbin==as.raw(1) | rtcwbin==as.raw(2) | rtcwbin==as.raw(3) |
        rtcwbin==as.raw(4) | rtcwbin==as.raw(5) | rtcwbin==as.raw(6) |  
        rtcwbin==as.raw(7) | rtcwbin==as.raw(8) | rtcwbin==as.raw(9) |
                             rtcwbin==as.raw(11) | rtcwbin==as.raw(12) |
        rtcwbin==as.raw(13) | rtcwbin==as.raw(14) | rtcwbin==as.raw(15) |
        rtcwbin==as.raw(16) | rtcwbin==as.raw(17) | rtcwbin==as.raw(18) |
        rtcwbin==as.raw(19) | rtcwbin==as.raw(20) | rtcwbin==as.raw(21) |
        rtcwbin==as.raw(22) | rtcwbin==as.raw(23) | rtcwbin==as.raw(24) |
        rtcwbin==as.raw(25) | rtcwbin==as.raw(26) | rtcwbin==as.raw(27) |
        rtcwbin==as.raw(28) | rtcwbin==as.raw(29) | rtcwbin==as.raw(30) | rtcwbin==as.raw(31)] = as.raw(0x20) ## replace with 0x20 = <space>
writeBin(rtcwbin, fileTXT)
}

con <- file(fileTXT, "r", blocking = FALSE)
dsrtcw <- readLines(con, skipNul = TRUE, encoding = "UTF-8")
close(con)


#dsrtcw <- dsrtcw[which(dsrtcw!="" & dsrtcw!=" ")]
#dsrtcw  <- gsub(pattern = "u0081", replace = "", x = dsrtcw)
#dsrtcw  <- gsub(pattern = "??", replace = "", x = dsrtcw)
#dsrtcw  <- gsub(pattern = "??", replace = "", x = dsrtcw)
dsrtcw <- gsub("<.*?>", "", dsrtcw)
dsrtcw <- gsub("Posted on (.*) Delete","",dsrtcw)

print(paste("Loaded RTCW file size: ", round(object.size(get("dsrtcw"))/1024/1024,1)," MB"))
print(paste("Loaded RTCW lines: ", length(dsrtcw)))
head(dsrtcw,10)







