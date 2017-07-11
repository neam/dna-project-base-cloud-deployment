BUILD_DIR="$(basename $(pwd))-build"
time vendor/bin/docker-stack build-directory-sync
cp deploy/config/deploy-prepare-secrets.php ../$BUILD_DIR/deploy/config/
cp deploy/config/secrets.php ../$BUILD_DIR/deploy/config/
cd "../$BUILD_DIR"
mkdir -p .files
mkdir -p stack/localdb/.db/mysql
stack/src/install-core-deps.sh
# TODO: Restore running the install commands within a container, currently not working probably due to shell init commands needs to be run first that sets permissions correctly etc
#time docker-compose run -e PREFER=dist builder stack/src/install-core-deps.sh
