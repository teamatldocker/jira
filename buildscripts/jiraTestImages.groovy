node('docker') {
    checkout scm
    sh './buildscripts/release.sh && ./buildscripts/cleanJiraContainers.sh'
    try {
      sh './buildscripts/release.sh && ./buildscripts/testSupportedJiraImages.sh'
    } finally {
      sh './buildscripts/release.sh && ./buildscripts/cleanJiraContainers.sh'
    }
}
