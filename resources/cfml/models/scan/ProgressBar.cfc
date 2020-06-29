component singleton {

	public function reset() {
		session.progress = { "percent"=0, "currentCount"=0, "totalCount"=0 };
	}

	public function update(numeric percent=0, numeric currentCount=0, totalCount=0 ) {
		if (!session.keyExists("progress")) {
			reset();
		}
		session.progress.percent = arguments.percent;
		session.progress.currentCount = arguments.currentCount;
		session.progress.totalCount = arguments.totalCount;
	}

	public function getValues() {
		if (!session.keyExists("progress")) {
			reset();
		}
		return session.progress;
	}


}