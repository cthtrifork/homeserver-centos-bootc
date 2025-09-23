module.exports = {
  "repositories": [
    "cthtrifork/homeserver-centos-bootc",
  ],
  hostRules: [
    {
      "hostType": 'docker',
      "matchHost": 'ghcr.io',
      "username": 'cthtrifork',
      "password": process.env.RENOVATE_PAT_TOKEN,
    }
  ]
}
